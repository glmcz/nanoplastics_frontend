/// Backend configuration for API endpoints
/// Build configuration:
/// - Emulator: flutter run --dart-define=BACKEND_URL=http://10.0.2.2:3000
class BackendConfig {
  /// Backend URL - MUST be provided via environment variable at build time
  ///
  /// Production builds MUST set BACKEND_URL via GitHub Actions secrets
  /// Local development can override with:
  ///   flutter run --dart-define=BACKEND_URL=http://10.0.2.2:3000
  ///
  /// If not provided, defaults to placeholder (will fail at runtime to catch misconfiguration)
  static const String defaultBackendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://10.0.2.2:3000',
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
