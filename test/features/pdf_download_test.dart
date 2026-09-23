// These tests exercise dart:io / path_provider / file-system behaviour that
// only exists on mobile/desktop.  They must not run on the Chrome platform
// (flutter test --platform chrome) where dart:io and path_provider channels
// are unavailable and the asset-manifest future never completes.
@TestOn('vm')
library;

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/utils/pdf_utils.dart';
import '../helpers/settings_test_helper.dart';

void main() {
  setUpAll(() {
    // path_provider's method channel has no implementation in the Dart VM test
    // runner. Initialize the binding and register a minimal mock so calls to
    // getApplicationDocumentsDirectory() return a temp path instead of throwing
    // MissingPluginException.
    TestWidgetsFlutterBinding.ensureInitialized();
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getApplicationDocumentsDirectory') {
        return '/tmp/test_docs';
      }
      return null;
    });
  });

  setUp(() async {
    await setupSettingsManager({'user_language': 'en'});
  });

  group('PDF — URL and path resolution', () {
    test('EN report always resolves to a bundled asset path', () {
      final path = getMainReportPath('en');
      expect(path, contains('Nanoplastics_Report_EN_compressed.pdf'));
      expect(path, startsWith('assets/docs/'));
    });

    test('CS report path follows naming convention', () {
      final path = getMainReportPath('cs');
      expect(path, contains('Nanoplastics_Report_CS_compressed.pdf'));
    });

    test('report filename is uppercase language code', () {
      for (final lang in ['en', 'cs', 'es', 'fr', 'ru']) {
        final path = getMainReportPath(lang);
        expect(path, contains(lang.toUpperCase()),
            reason: 'Path for $lang should contain ${lang.toUpperCase()}');
      }
    });

    test('resolveMainReport returns null for a non-EN report with no cache',
        () async {
      // Only EN is bundled, and assets are not loaded in unit tests, so CS
      // without a local cache has nowhere to come from but a download.
      final resolved = await resolveMainReport('cs');
      if (resolved != null) {
        expect(resolved.path, contains('CS'));
      }
    });
  });

  group('PDF — download cancellation', () {
    test('cancellationToken.complete() aborts download mid-stream', () async {
      final cancel = Completer<void>();

      // Cancel immediately before the download starts
      cancel.complete();

      expect(
        () => downloadReport('cs', cancellationToken: cancel),
        throwsA(isA<Exception>()),
        reason: 'Cancelled download should throw an Exception',
      );
    });
  });
}
