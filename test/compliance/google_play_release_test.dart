@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/config/store_links.dart';

void main() {
  final playManifest = File('android/app/src/play/AndroidManifest.xml');
  final buildGradle = File('android/app/build.gradle.kts');
  final webPolicy = File('assets/l10n_web/web_en.arb');

  group('Google Play release compliance checks', () {
    test('Play flavor removes restricted storage and install permissions', () {
      final manifestContent = playManifest.readAsStringSync();
      final permissionPattern = RegExp(
        r'<uses-permission\b([^>]*)android:name="([^"]+)"([^>]*)tools:node="remove"[^>]*/>',
        caseSensitive: false,
        dotAll: true,
      );
      final removedPermissions = <String>{
        for (final match in permissionPattern.allMatches(manifestContent))
          match.group(2)!
      };

      for (final restricted in [
        'android.permission.MANAGE_EXTERNAL_STORAGE',
        'android.permission.REQUEST_INSTALL_PACKAGES',
        'android.permission.WRITE_EXTERNAL_STORAGE',
        'android.permission.READ_EXTERNAL_STORAGE',
      ]) {
        expect(
          removedPermissions.contains(restricted),
          isTrue,
          reason:
              'Play manifest must explicitly remove $restricted for Play Store compliance',
        );
      }
    });

    test('Project defines a Play-specific flavor for sanitized Play builds',
        () {
      final gradleContent = buildGradle.readAsStringSync();
      expect(
        gradleContent.contains('create("play")'),
        isTrue,
        reason:
            'Build definitions must expose a Play flavor that can drop unsafe permissions',
      );
    });

    // The store listings link here; the web app serves it under /privacy.
    test('Privacy policy is public at web.nanosolve.org/privacy', () {
      expect(StoreLinks.privacy, 'https://web.nanosolve.org/privacy');
      final policy = jsonDecode(webPolicy.readAsStringSync()) as Map;
      expect(policy['privacyPageTitle'], 'Privacy Policy');
    });
  });
}
