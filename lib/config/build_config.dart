/// Build-time configuration flags passed via --dart-define.
///
/// Usage:
///   Lite (EN only):  flutter build apk --flavor lite --dart-define=BUNDLE_ALL_LANGS=false
///   Full (all langs): flutter build apk --flavor full --dart-define=BUNDLE_ALL_LANGS=true
class BuildConfig {
  BuildConfig._();

  /// Whether all language PDFs are bundled as assets.
  /// When false (default), only EN is available as an asset; other languages
  /// are downloaded on demand.
  static const bundleAllLangs = bool.fromEnvironment(
    'BUNDLE_ALL_LANGS',
    defaultValue: false,
  );

  /// Whether this is a Play Store build (disables self-update).
  /// When true, the update service is disabled (uses Play Store in-app updates instead).
  /// Set via: flutter build appbundle --dart-define=IS_PLAY_STORE=true
  static const isPlayStoreBuild = bool.fromEnvironment(
    'IS_PLAY_STORE',
    defaultValue: false,
  );
}
