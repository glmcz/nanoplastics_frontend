import 'package:flutter/foundation.dart';

/// Build-time configuration flags passed via --dart-define.
///
/// Usage:
///   flutter build apk --flavor full
///   flutter build appbundle --flavor play --dart-define=IS_PLAY_STORE=true
class BuildConfig {
  BuildConfig._();

  /// Whether this is a Play Store build (disables self-update).
  /// When true, the update service is disabled (uses Play Store in-app updates instead).
  /// Set via: flutter build appbundle --dart-define=IS_PLAY_STORE=true
  static const isPlayStoreBuild = bool.fromEnvironment(
    'IS_PLAY_STORE',
    defaultValue: false,
  );

  /// Distribution channel — drives which update adapter gets injected.
  ///
  ///   --dart-define=DISTRIBUTION=github     → GitHub APK (self-update enabled, default)
  ///   --dart-define=DISTRIBUTION=playStore  → Google Play (store handles updates)
  ///   --dart-define=DISTRIBUTION=appStore   → Apple App Store (store handles updates)
  ///
  /// Kept as a raw const string so downstream `isXxx` flags are compile-time
  /// constants — required for Dart AOT tree-shaking to drop the unused
  /// update-service implementation from non-GitHub bundles.
  static const _distribution = String.fromEnvironment(
    'DISTRIBUTION',
    defaultValue: 'github',
  );

  /// True for the direct-APK GitHub build (only channel that self-updates).
  static const isGithubBuild = _distribution == 'github';

  /// True for any store build (Play or App Store). Self-update must be disabled.
  static const isStoreBuild =
      _distribution == 'playStore' || _distribution == 'appStore';

  /// Whether this build may run the self-updater.
  ///
  /// The distribution flag alone is not enough. It defaults to `github`, so an
  /// iOS build that forgets `--dart-define=DISTRIBUTION=appStore` used to get
  /// the real updater, which compares the installed version against the GitHub
  /// APK release feed, paints a red badge on a brand new install, and offers a
  /// download iOS cannot install. The platform check cannot be forgotten.
  ///
  /// Deliberately a runtime check rather than a compile-time constant: being
  /// unable to forget it is worth more than tree-shaking a few kilobytes.
  static bool get selfUpdateSupported => selfUpdateSupportedFor(
        isGithub: isGithubBuild,
        isWeb: kIsWeb,
        platform: defaultTargetPlatform,
      );

  /// The rule itself, with every input passed in.
  ///
  /// Split out so tests can state a case fully instead of depending on how
  /// the suite happened to be invoked: `isGithubBuild` reads a --dart-define,
  /// so a run that passes DISTRIBUTION would silently change the answer and
  /// fail a test that had nothing to do with the flag.
  @visibleForTesting
  static bool selfUpdateSupportedFor({
    required bool isGithub,
    required bool isWeb,
    required TargetPlatform platform,
  }) =>
      isGithub && !isWeb && platform == TargetPlatform.android;
}
