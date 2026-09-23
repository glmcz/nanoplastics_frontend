import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/services/pdf_service.dart';
import 'package:nanoplastics_app/services/settings_manager.dart';
import '../helpers/settings_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('bundled PDF extraction and app startup', () {
    setUp(() async {
      await setupServiceLocator();
    });

    // Extraction copies up to seven bundled PDFs on the full flavour. Awaiting
    // it before runApp put all of that file I/O in front of the first frame,
    // including on a launch from a notification tap, which never opens a PDF.
    test('initialize returns without waiting for extraction to finish',
        () async {
      final gate = Completer<void>();
      final pdf = PdfService(SettingsManager(), extractor: () => gate.future);

      var extractionDone = false;
      unawaited(pdf.ready.then((_) => extractionDone = true));

      pdf.initialize();
      await Future.delayed(Duration.zero);

      expect(extractionDone, isFalse, reason: 'extraction is still running');

      gate.complete();
      await pdf.ready;

      expect(extractionDone, isTrue);
    });

    test('extraction runs once however many times initialize is called',
        () async {
      var runs = 0;
      final pdf = PdfService(
        SettingsManager(),
        extractor: () async => runs++,
      );

      pdf.initialize();
      pdf.initialize();
      pdf.initialize();
      await pdf.ready;

      expect(runs, 1);
    });

    test('resolvePdf waits for extraction rather than racing it', () async {
      final gate = Completer<void>();
      final pdf = PdfService(SettingsManager(), extractor: () => gate.future);
      pdf.initialize();

      var resolved = false;
      // Resolution itself fails in the test VM (no path_provider); what is
      // asserted is that it did not even start until extraction finished.
      unawaited(pdf
          .resolvePdf(language: 'en')
          .then((_) => resolved = true, onError: (_) => resolved = true));
      await Future.delayed(Duration.zero);

      expect(resolved, isFalse, reason: 'must not read files mid-extraction');

      gate.complete();
      await pdf.ready;
      await Future.delayed(const Duration(milliseconds: 50));

      expect(resolved, isTrue);
    });
  });
}
