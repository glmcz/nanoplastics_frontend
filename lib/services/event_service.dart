import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../config/backend_config.dart';

/// Usage funnel.
///
/// Carries no personal data. `install_id` is a random uuid made on this
/// device, unrelated to the user id, and it disappears when app data is
/// cleared. Props are small enumerated values; never free text, habit
/// answers, or coordinates.
class EventService {
  static const String _installIdKey = 'install_id';

  /// Matches the backend's batch cap. Queuing more than the server accepts
  /// would only guarantee a rejected request.
  static const int maxBatch = 50;

  @visibleForTesting
  http.Client client = http.Client();

  bool _enabled = false;
  String _installId = '';
  final List<Map<String, Object?>> _queue = [];

  String get installId => _installId;
  bool get isEnabled => _enabled;
  int get debugQueueLength => _queue.length;

  Future<void> init({required bool enabled}) async {
    _enabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_installIdKey);
    if (id == null || id.isEmpty) {
      id = const Uuid().v4();
      await prefs.setString(_installIdKey, id);
    }
    _installId = id;
  }

  /// Off means nothing is collected, not merely nothing sent. Anything
  /// already queued is discarded.
  void setEnabled(bool value) {
    _enabled = value;
    if (!value) _queue.clear();
  }

  void log(String name, {Map<String, Object?> props = const {}}) {
    if (!_enabled) return;
    if (_queue.length >= maxBatch) return;
    _queue.add({
      'install_id': _installId,
      'name': name,
      // PlatformDispatcher rather than WidgetsBinding: this service must work
      // without a widget binding, so it can be tested and so it can flush
      // during app shutdown.
      'locale': PlatformDispatcher.instance.locale.languageCode,
      'platform': defaultTargetPlatform.name,
      'props': props,
    });
  }

  /// True when the last flush reached the server and it accepted the batch.
  /// Exposed so a test can tell a real failure from a silent no-op; nothing
  /// in the app changes behaviour based on it.
  bool get lastFlushSucceeded => _lastFlushSucceeded;
  bool _lastFlushSucceeded = false;

  /// Best effort. A failure drops the batch rather than growing a queue that
  /// would eventually post a month of stale events in one request.
  ///
  /// Both failure modes are handled: a thrown exception when the network is
  /// gone, and a non-2xx response, which `http` returns normally rather than
  /// throwing.
  Future<void> flush() async {
    if (!_enabled || _queue.isEmpty) return;
    final batch = List<Map<String, Object?>>.from(_queue);
    _queue.clear();
    _lastFlushSucceeded = false;
    try {
      final response = await client
          .post(
            Uri.parse('${BackendConfig.getBaseUrl()}/api/events'),
            headers: const {'content-type': 'application/json'},
            body: jsonEncode(batch),
          )
          .timeout(const Duration(seconds: 8));
      _lastFlushSucceeded =
          response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      // Deliberately silent: a dropped usage event is not worth a log line
      // in front of the student, and the queue is already cleared.
      _lastFlushSucceeded = false;
    }
  }
}
