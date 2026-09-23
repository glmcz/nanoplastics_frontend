import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/digest_paper.dart';
import 'api_service.dart';
import 'http/app_http_client.dart';
import 'logger_service.dart';
import 'settings_manager.dart';

class DigestService {
  static final DigestService _instance = DigestService._internal();
  DigestService._internal();

  static DigestService? _testOverride;

  factory DigestService() => _testOverride ?? _instance;

  @visibleForTesting
  static void overrideForTesting(DigestService? svc) => _testOverride = svc;

  final _api = ApiService();
  final _settings = SettingsManager();

  // In-memory tresor cache — populated on syncUser(), updated on add/remove
  final Set<String> _tresorIds = {};
  Set<String> get tresorIds => Set.unmodifiable(_tresorIds);

  // ── User sync ────────────────────────────────────────────────────────────────

  /// Called fire-and-forget on app start. Upserts user, warms tresor cache.
  Future<void> syncUser() async {
    final email = _settings.email;
    if (email.isEmpty) return;

    try {
      // Try to get existing user
      final meUri = Uri.parse(
          '${_api.baseUrl}/api/users/me?email=${Uri.encodeComponent(email)}');
      final meResp = await AppHttpClient.instance
          .get(meUri)
          .timeout(const Duration(seconds: 8));

      if (meResp.statusCode == 404) {
        // Register new user
        final regResp = await AppHttpClient.instance
            .post(
              Uri.parse('${_api.baseUrl}/api/users/register'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'email': email,
                'display_name': _settings.displayName,
              }),
            )
            .timeout(const Duration(seconds: 8));

        if (regResp.statusCode == 201) {
          _syncKeywordsFromJson(regResp.body);
        }
      } else if (meResp.statusCode == 200) {
        _syncKeywordsFromJson(meResp.body);
      }

      await _loadTresorIds(email);
    } catch (e) {
      LoggerService()
          .logUserAction('digest_sync_failed', params: {'error': e.toString()});
    }
  }

  void _syncKeywordsFromJson(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final kws = (json['search_keywords'] as List<dynamic>?)?.cast<String>();
      if (kws != null) {
        _settings.setDigestKeywords(kws);
      }
    } catch (_) {}
  }

  Future<void> _loadTresorIds(String email) async {
    final ids = await getTresorIds(email: email);
    _tresorIds
      ..clear()
      ..addAll(ids);
  }

  // ── Feed ─────────────────────────────────────────────────────────────────────

  Future<List<DigestPaper>> fetchLatest({
    DateTime? since,
    List<String>? keywords,
  }) async {
    final sinceDate = since ?? DateTime.now().subtract(const Duration(days: 7));
    final dateStr =
        '${sinceDate.year}-${sinceDate.month.toString().padLeft(2, '0')}-${sinceDate.day.toString().padLeft(2, '0')}';

    var url = '${_api.baseUrl}/api/digest/latest?since=$dateStr';
    if (keywords != null && keywords.isNotEmpty) {
      url += '&keywords=${Uri.encodeComponent(keywords.join(','))}';
    }

    final resp = await AppHttpClient.instance
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 15));
    if (resp.statusCode != 200) return [];

    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    final list = json['papers'] as List<dynamic>? ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(DigestPaper.fromJson)
        .toList();
  }

  Future<DigestPaper?> fetchPaperById(String paperId) async {
    try {
      final resp = await AppHttpClient.instance
          .get(Uri.parse('${_api.baseUrl}/api/digest/paper/$paperId'))
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) {
        LoggerService()
            .logError('fetchPaperById', 'HTTP ${resp.statusCode}', null);
        return null;
      }
      return DigestPaper.fromJson(
          jsonDecode(resp.body) as Map<String, dynamic>);
    } catch (e, st) {
      LoggerService().logError('fetchPaperById', e, st);
      return null;
    }
  }

  // ── Preferences ──────────────────────────────────────────────────────────────

  Future<bool> updatePreferences({
    bool? enabled,
    int? digestHour,
    List<String>? keywords,
  }) async {
    final email = _settings.email;
    if (email.isEmpty) {
      LoggerService()
          .logError('updatePreferences', 'email empty, skipping PUT');
      return false;
    }

    try {
      final body = <String, dynamic>{'email': email};
      if (enabled != null) body['daily_digest_enabled'] = enabled;
      if (digestHour != null) {
        body['digest_hour'] = digestHour;
      }
      if (keywords != null) body['search_keywords'] = keywords;

      final url = '${_api.baseUrl}/api/users/preferences';
      final resp = await AppHttpClient.instance
          .put(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      LoggerService()
          .logNetworkCall(url, method: 'PUT', statusCode: resp.statusCode);
      if (resp.statusCode != 200) {
        LoggerService().logError(
            'updatePreferences', 'status ${resp.statusCode}: ${resp.body}');
      }

      if (resp.statusCode == 200 && keywords != null) {
        _settings.setDigestKeywords(keywords);
      }

      return resp.statusCode == 200;
    } catch (e, st) {
      LoggerService().logError('updatePreferences', e, st);
      return false;
    }
  }

  List<String> getKeywords() {
    return _settings.digestKeywords;
  }

  /// Fetches the user's current digest preferences from the server, or
  /// null if the user doesn't exist yet / the request fails.
  Future<({bool enabled, int digestHour})?> fetchPreferences() async {
    final email = _settings.email;
    if (email.isEmpty) return null;

    try {
      final resp = await AppHttpClient.instance
          .get(Uri.parse(
              '${_api.baseUrl}/api/users/me?email=${Uri.encodeComponent(email)}'))
          .timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) return null;

      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      return (
        enabled: json['daily_digest_enabled'] as bool? ?? true,
        digestHour: json['digest_hour'] as int? ?? 9,
      );
    } catch (_) {
      return null;
    }
  }

  // ── Tresor ───────────────────────────────────────────────────────────────────

  Future<List<String>> getTresorIds({String? email}) async {
    final resolvedEmail = email ?? _settings.email;
    if (resolvedEmail.isEmpty) return [];

    try {
      final resp = await AppHttpClient.instance
          .get(
            Uri.parse(
                '${_api.baseUrl}/api/users/tresor?email=${Uri.encodeComponent(resolvedEmail)}'),
          )
          .timeout(const Duration(seconds: 10));

      if (resp.statusCode != 200) return [];
      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      return ((json['paper_ids'] as List<dynamic>?) ?? []).cast<String>();
    } catch (_) {
      return [];
    }
  }

  Future<bool> addToTresor(String paperId) async {
    final email = _settings.email;
    if (email.isEmpty) return false;

    try {
      final resp = await AppHttpClient.instance
          .post(
            Uri.parse('${_api.baseUrl}/api/users/tresor'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'paper_id': paperId}),
          )
          .timeout(const Duration(seconds: 8));

      if (resp.statusCode == 201) {
        _tresorIds.add(paperId);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeFromTresor(String paperId) async {
    final email = _settings.email;
    if (email.isEmpty) return false;

    try {
      final resp = await AppHttpClient.instance
          .delete(
            Uri.parse(
                '${_api.baseUrl}/api/users/tresor/$paperId?email=${Uri.encodeComponent(email)}'),
          )
          .timeout(const Duration(seconds: 8));

      if (resp.statusCode == 204) {
        _tresorIds.remove(paperId);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> updateFcmToken(String token) async {
    final email = _settings.email;
    if (email.isEmpty) {
      LoggerService().logError(
          'updateFcmToken', 'no email set — push token not registered', null);
      return;
    }

    try {
      final resp = await AppHttpClient.instance
          .put(
            Uri.parse('${_api.baseUrl}/api/users/fcm-token'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'token': token}),
          )
          .timeout(const Duration(seconds: 8));
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        LoggerService().logError(
            'updateFcmToken', 'HTTP ${resp.statusCode}: ${resp.body}', null);
      }
    } catch (e, st) {
      // Silence here meant a device that could never be pushed to, with nothing
      // anywhere to say so.
      LoggerService().logError('updateFcmToken', e, st);
    }
  }

  Future<List<DigestPaper>> fetchSavedPapers() async {
    final email = _settings.email;
    if (email.isEmpty) return [];

    try {
      final resp = await AppHttpClient.instance
          .get(
            Uri.parse(
                '${_api.baseUrl}/api/users/tresor/papers?email=${Uri.encodeComponent(email)}'),
          )
          .timeout(const Duration(seconds: 15));

      if (resp.statusCode != 200) return [];
      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final list = json['papers'] as List<dynamic>? ?? [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(DigestPaper.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<String?> exportTresor() async {
    final email = _settings.email;
    if (email.isEmpty) return null;

    try {
      final resp = await AppHttpClient.instance
          .get(
            Uri.parse(
                '${_api.baseUrl}/api/users/tresor/export?email=${Uri.encodeComponent(email)}'),
          )
          .timeout(const Duration(seconds: 15));

      return resp.statusCode == 200 ? resp.body : null;
    } catch (_) {
      return null;
    }
  }
}
