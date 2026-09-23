import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/config/build_config.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  // Every input is stated, so the outcome cannot change with how the suite
  // was invoked. isGithubBuild reads a --dart-define, and a run that passes
  // DISTRIBUTION used to fail these for reasons unrelated to the rule.
  group('the rule', () {
    bool rule(bool isGithub, bool isWeb, TargetPlatform p) =>
        BuildConfig.selfUpdateSupportedFor(
            isGithub: isGithub, isWeb: isWeb, platform: p);

    test('Android with a github distribution may self-update', () {
      expect(rule(true, false, TargetPlatform.android), isTrue);
    });

    test('iOS may never self-update, whatever the distribution flag says', () {
      expect(
        rule(true, false, TargetPlatform.iOS),
        isFalse,
        reason: 'the self-updater downloads and installs an APK, which iOS '
            'cannot do. Leaving it enabled paints a red update badge on a '
            'fresh install and offers a page of Android builds.',
      );
      expect(rule(false, false, TargetPlatform.iOS), isFalse);
    });

    test('no other platform may self-update', () {
      for (final p in [
        TargetPlatform.macOS,
        TargetPlatform.windows,
        TargetPlatform.linux,
        TargetPlatform.fuchsia,
      ]) {
        expect(rule(true, false, p), isFalse, reason: '$p');
      }
    });

    test('a store distribution may not self-update even on Android', () {
      expect(rule(false, false, TargetPlatform.android), isFalse);
    });

    test('web may not self-update', () {
      expect(rule(true, true, TargetPlatform.android), isFalse);
    });
  });

  group('the shipped getter', () {
    test('is false on iOS regardless of how this suite was invoked', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(BuildConfig.selfUpdateSupported, isFalse);
    });

    test('agrees with the rule for the current build flags', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(
        BuildConfig.selfUpdateSupported,
        BuildConfig.selfUpdateSupportedFor(
          isGithub: BuildConfig.isGithubBuild,
          isWeb: kIsWeb,
          platform: TargetPlatform.android,
        ),
      );
    });
  });
}
