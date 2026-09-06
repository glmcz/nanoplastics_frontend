import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/config/app_constants.dart';
import 'package:nanoplastics_app/screens/main_screen.dart';

import '../helpers/responsive_test_helper.dart';
import '../helpers/settings_test_helper.dart';
import '../helpers/test_app.dart';

const kIPhoneSE2022 = DeviceProfile(
  'iPhone SE 2022',
  width: 375,
  height: 667,
);
const kMotoG32Viewport = DeviceProfile(
  'Moto G32 viewport',
  width: 351,
  height: 642,
);

Future<void> _pumpMainScreen(WidgetTester tester, DeviceProfile device) async {
  setScreenSize(tester, device);
  await tester.pumpWidget(buildTestableWidget(const MainScreen()));
  await tester.pumpAndSettle();
}

Future<void> _pumpLocalizedMainScreen(
  WidgetTester tester,
  DeviceProfile device, {
  Locale locale = const Locale('en'),
}) async {
  setScreenSize(tester, device);
  await tester.pumpWidget(
    buildTestableWidget(const MainScreen(), locale: locale),
  );
  await tester.pumpAndSettle();
}

List<String> _drainExceptions(WidgetTester tester) {
  final messages = <String>[];
  while (true) {
    final error = tester.takeException();
    if (error == null) break;
    messages.add(error.toString());
  }
  return messages;
}

const _humanIcons = [
  Icons.psychology_outlined,
  Icons.water_drop_outlined,
  Icons.favorite_outline,
  Icons.child_care_outlined,
  Icons.air_outlined,
  Icons.science_outlined,
];

const _planetIcons = [
  Icons.waves_outlined,
  Icons.cloud_outlined,
  Icons.nature_outlined,
  Icons.explore_outlined,
  Icons.delete_outline,
  Icons.hub_outlined,
];

List<Rect> _cardRects(WidgetTester tester, {bool planetTab = false}) {
  final icons = planetTab ? _planetIcons : _humanIcons;
  final rects = <Rect>[];
  for (final icon in icons) {
    final iconFinder = find.byIcon(icon);
    if (iconFinder.evaluate().isEmpty) continue;
    final cardFinder = find.ancestor(
      of: iconFinder.first,
      matching: find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.button == true,
      ),
    );
    if (cardFinder.evaluate().isEmpty) continue;
    rects.add(tester.getRect(cardFinder.first));
  }
  rects.sort((a, b) {
    final rowCompare = a.top.compareTo(b.top);
    return rowCompare != 0 ? rowCompare : a.left.compareTo(b.left);
  });
  return rects;
}

double _gapBetweenLastRowAndHub(DeviceProfile device, List<Rect> rects) {
  final hubTop = device.height - sizingFor(device).hubContainerHeight;
  return hubTop - rects.take(6).last.bottom;
}

void main() {
  setUp(() async {
    await setupServiceLocator();
  });

  group('Category grid small screens', () {
    for (final device in [kMotoG32Viewport, kIPhoneSE2022, kTinyPhone]) {
      testWidgets('$device renders without layout exceptions', (tester) async {
        await _pumpMainScreen(tester, device);

        final errors = _drainExceptions(tester)
            .where((message) =>
                message.contains('overflowed') || message.contains('unbounded'))
            .toList();

        expect(
          errors,
          isEmpty,
          reason: 'Layout still breaks on $device: ${errors.join(' | ')}',
        );
        expect(
          _cardRects(tester).length,
          greaterThanOrEqualTo(6),
          reason: 'Expected 6 category cards on $device.',
        );
      });
    }

    testWidgets(
        '351x642 does not leave a blank band above the hub when cards grow',
        (tester) async {
      await _pumpMainScreen(tester, kMotoG32Viewport);

      final rects = _cardRects(tester);
      expect(rects.length, greaterThanOrEqualTo(6));

      final expectedBottomGap = spacingFor(kMotoG32Viewport).md * 0.7;
      final actualBottomGap = _gapBetweenLastRowAndHub(kMotoG32Viewport, rects);

      expect(
        actualBottomGap,
        lessThanOrEqualTo(expectedBottomGap + 4.0),
        reason: 'The grid is still leaving unused vertical space on the '
            '351x642 viewport instead of using it for taller category cards.',
      );
    });

    testWidgets('351x642 keeps all category cards at the same height',
        (tester) async {
      await _pumpMainScreen(tester, kMotoG32Viewport);

      final rects = _cardRects(tester).take(6).toList();
      expect(rects.length, 6);

      final heights = rects.map((rect) => rect.height).toList();
      final minHeight = heights.reduce((a, b) => a < b ? a : b);
      final maxHeight = heights.reduce((a, b) => a > b ? a : b);

      expect(
        maxHeight - minHeight,
        lessThanOrEqualTo(2.0),
        reason: 'Small-screen cards no longer share the same row height: '
            '$heights',
      );
      expect(
        minHeight,
        greaterThanOrEqualTo(AppConstants.categoryCardMinHeight),
        reason: 'Small-screen category cards should stay readable instead of '
            'being compressed to tiny heights.',
      );
    });

    testWidgets('351x642 Russian planet tab renders without overflow',
        (tester) async {
      await _pumpLocalizedMainScreen(
        tester,
        kMotoG32Viewport,
        locale: const Locale('ru'),
      );

      final planetButton = tester.widget<InkWell>(
        find.byKey(const ValueKey('hub-button-planet')),
      );
      planetButton.onTap?.call();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();

      final errors = _drainExceptions(tester)
          .where((message) =>
              message.contains('overflowed') || message.contains('unbounded'))
          .toList();

      expect(
        errors,
        isEmpty,
        reason: 'Russian planet categories still overflow on 351x642: '
            '${errors.join(' | ')}',
      );
      expect(
        _cardRects(tester, planetTab: true).length,
        greaterThanOrEqualTo(6),
      );
    });
  });

  // ── Big-screen tests ──────────────────────────────────────────────────────
  // isBig = !isCompact && (width > 410 || height > 900).
  // Card icon/padding no longer use categoryScale (removed to avoid overflow
  // when 2-line titles + 2-line descriptions are both shown).
  // Fixed rowHeight from LayoutBuilder still fills screen.

  const kBigDevices = [kiPhone14Plus, kXLarge, kVeryTallSlim];

  group('Category grid big screens', () {
    for (final device in kBigDevices) {
      testWidgets('$device renders without layout exceptions', (tester) async {
        await _pumpMainScreen(tester, device);

        final errors = _drainExceptions(tester)
            .where((message) =>
                message.contains('overflowed') || message.contains('unbounded'))
            .toList();

        expect(
          errors,
          isEmpty,
          reason: 'Layout breaks on $device: ${errors.join(' | ')}',
        );
        expect(
          _cardRects(tester).length,
          greaterThanOrEqualTo(6),
          reason: 'Expected 6 category cards on $device.',
        );
      });
    }

    testWidgets('428x926 keeps all category cards at the same height',
        (tester) async {
      await _pumpMainScreen(tester, kiPhone14Plus);

      final rects = _cardRects(tester).take(6).toList();
      expect(rects.length, 6);

      final heights = rects.map((r) => r.height).toList();
      final minH = heights.reduce((a, b) => a < b ? a : b);
      final maxH = heights.reduce((a, b) => a > b ? a : b);

      expect(
        maxH - minH,
        lessThanOrEqualTo(2.0),
        reason:
            'Big-screen cards no longer share the same row height: $heights',
      );
      expect(
        minH,
        greaterThanOrEqualTo(AppConstants.categoryCardMinHeight),
        reason: 'Big-screen cards should not be compressed below minHeight.',
      );
    });

    testWidgets('428x926 does not leave a blank band above the hub',
        (tester) async {
      await _pumpMainScreen(tester, kiPhone14Plus);

      final rects = _cardRects(tester);
      expect(rects.length, greaterThanOrEqualTo(6));

      final expectedBottomGap = spacingFor(kiPhone14Plus).md * 0.7;
      final actualBottomGap = _gapBetweenLastRowAndHub(kiPhone14Plus, rects);

      expect(
        actualBottomGap,
        lessThanOrEqualTo(expectedBottomGap + 4.0),
        reason: 'Big-screen grid leaves unused vertical space on 428x926.',
      );
    });

    testWidgets('428x926 French planet tab renders without overflow',
        (tester) async {
      await _pumpLocalizedMainScreen(
        tester,
        kiPhone14Plus,
        locale: const Locale('fr'),
      );

      final planetButton = tester.widget<InkWell>(
        find.byKey(const ValueKey('hub-button-planet')),
      );
      planetButton.onTap?.call();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();

      final errors = _drainExceptions(tester)
          .where((message) =>
              message.contains('overflowed') || message.contains('unbounded'))
          .toList();

      expect(
        errors,
        isEmpty,
        reason: 'French long titles overflow on 428x926 planet tab: '
            '${errors.join(' | ')}',
      );
      expect(
        _cardRects(tester, planetTab: true).length,
        greaterThanOrEqualTo(6),
      );
    });
  });
}
