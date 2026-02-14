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
}
