import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:http/http.dart' as http;

import 'trusted_http_client_web.dart'
    if (dart.library.io) 'trusted_http_client_io.dart';

/// The app's single HTTP client.
///
/// Everything that talks to the network goes through [instance], so the
/// certificate trust configuration lives in exactly one place. The underlying
/// client is built once and reused: a SecurityContext costs an asset read plus
/// a certificate parse, and a fresh HttpClient per request leaks its
/// connection pool.
///
/// The default branch of the conditional import is the web implementation.
/// `dart.library.io` is false on both dart2js and dart2wasm, so the web build
/// never reaches the dart:io code; testing `dart.library.html` instead would
/// pick the wrong branch under wasm.
class AppHttpClient extends http.BaseClient {
  AppHttpClient._();

  static final AppHttpClient instance = AppHttpClient._();

  /// Whether this build adds the bundled ISRG Root X1 to its trust store.
  /// False on the web, where the browser supplies trust.
  static bool get usesBundledRootCertificate => kUsesBundledRootCertificate;

  http.Client? _resolved;
  Future<http.Client>? _pending;

  /// The built client, or null while it is still being built.
  ///
  /// [send] checks this before awaiting anything. That is not just a
  /// micro-optimisation: a memoised Future is bound to the zone that created
  /// it, and in widget tests each `testWidgets` body runs in its own FakeAsync
  /// zone, so a Future carried over from an earlier test would schedule its
  /// continuation into a microtask queue that is never drained again.
  @visibleForTesting
  http.Client? get resolved => _resolved;

  Future<http.Client> _build() =>
      _pending ??= buildTrustedHttpClient().then((client) {
        _resolved = client;
        return client;
      });

  /// Builds the client before the first request needs it.
  ///
  /// Reading and parsing the bundled root is an asset read; on the first API
  /// call it would sit in front of that request.
  Future<void> warmUp() async {
    await _build();
  }

  @visibleForTesting
  Future<http.Client> get delegateForTesting => _build();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final ready = _resolved;
    if (ready != null) return ready.send(request);
    return _build().then((client) => client.send(request));
  }

  @override
  void close() {
    final pending = _pending;
    _pending = null;
    _resolved = null;
    pending?.then((client) => client.close()).ignore();
  }
}
