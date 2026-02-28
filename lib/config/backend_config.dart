/// Backend configuration for API endpoints
/// Build configuration:
/// - Production: https://nanosolve.duckdns.org (default)
/// - Emulator: flutter run --dart-define=BACKEND_URL=http://10.0.2.2:3000
/// - Local: flutter run --dart-define=BACKEND_URL=http://localhost:3000
class BackendConfig {
  /// Backend URL - can be overridden via environment variable at build time
  ///
  /// Production default: https://nanosolve.duckdns.org (HTTPS required for Play Store)
  /// Local development can override with:
  ///   flutter run --dart-define=BACKEND_URL=http://10.0.2.2:3000 (emulator)
  ///   flutter run --dart-define=BACKEND_URL=http://localhost:3000 (local machine)
  ///
  /// Network security policy (Android):
  /// - HTTPS required for all domains except emulator IP 10.0.2.2
  /// - See: android/app/src/main/res/xml/network_security_config.xml
  static const String defaultBackendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'https://nanosolve.duckdns.org',
  );

  /// Get the current backend base URL
  /// This can be customized at build time using:
  static String getBaseUrl() {
    return defaultBackendUrl;
  }

  /// Health check endpoint
  static String getHealthUrl() => '${getBaseUrl()}/health';

  /// Ideas API endpoint
  static String getIdeasUrl() => '${getBaseUrl()}/api/ideas';

  /// Solvers leaderboard endpoint
  static String getSolversUrl() => '${getBaseUrl()}/api/solvers';

  /// PDF metadata and download endpoint
  static String getPdfMetadataUrl(String language) =>
      '${getBaseUrl()}/api/pdfs/$language';

  /// Get human-readable environment name for logging
  static String getEnvironment() {
    final url = getBaseUrl();
    if (url.contains('10.0.2.2')) {
      return 'emulator';
    } else if (url.contains('localhost') || url.contains('127.0.0.1')) {
      return 'local';
    }
    return 'production'; // Any other URL is assumed production
  }
}
