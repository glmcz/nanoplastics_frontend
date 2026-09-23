// Layout of a mobile screen at real device sizes. The Chrome platform
// (flutter test --platform chrome) renders text with different metrics and
// has no dart:io, so overflow assertions made for phones do not hold there.
@TestOn('vm')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/screens/paper_loader_screen.dart';
import '../helpers/responsive_test_helper.dart';
import '../helpers/settings_test_helper.dart';
import '../helpers/test_app.dart';

/// The perex now arrives in the push payload and is drawn before any fetch, so
/// this screen renders up to 600 characters of text it never used to hold.
/// A Column that is only as tall as its children overflows once that text is
/// longer than the phone — worst on a short device at 200% text scale.
void main() {
  const longPerex =
      'Electrocoagulation with aluminium or iron electrodes removed 175 nm '
      'polystyrene nanoplastics from simulated urban treated wastewater via '
      'sweep flocculation by in-situ metal (oxy)hydroxides, with removal '
      'efficiency tracked across pH, current density and electrolysis time, '
      'and the resulting flocs characterised by SEM-EDS and FTIR to confirm '
      'the capture mechanism rather than infer it from turbidity alone. '
      'Reported under conditions a second laboratory could reproduce.';

  const longTitle =
      'Mechanistic insights into electrocoagulation-driven removal of '
      'polystyrene nanoplastics from urban treated wastewater';

  setUp(() async {
    await setupServiceLocator();
  });

  group('PaperLoaderScreen fits the payload it is given', () {
    for (final device in kPortraitDevices) {
      testWidgets('no overflow on ${device.name}', (tester) async {
        setScreenSize(tester, device);
        await tester.pumpWidget(buildTestableWidget(
          const PaperLoaderScreen(
            paperId: 'abc',
            previewTitle: longTitle,
            previewPerex: longPerex,
          ),
        ));
        await tester.pump();
      });
    }

    testWidgets('no overflow on the shortest phone at 200% text scale',
        (tester) async {
      setScreenSize(tester, kTinyPhone);
      await tester.pumpWidget(buildTestableWidget(
        const PaperLoaderScreen(
          paperId: 'abc',
          previewTitle: longTitle,
          previewPerex: longPerex,
        ),
        textScaleFactor: 2.0,
      ));
      await tester.pump();
    });

    testWidgets('no overflow in landscape', (tester) async {
      setScreenSize(tester, kiPhone14Landscape);
      await tester.pumpWidget(buildTestableWidget(
        const PaperLoaderScreen(
          paperId: 'abc',
          previewTitle: longTitle,
          previewPerex: longPerex,
        ),
      ));
      await tester.pump();
    });
  });
}
