import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/features/footprint/chapters.dart';
import 'package:nanoplastics_app/features/footprint/footprint_types.dart';
import 'package:nanoplastics_app/screens/footprint/footprint_result_screen.dart';
import 'package:nanoplastics_app/screens/footprint/footprint_story_screen.dart';
import 'package:nanoplastics_app/widgets/footprint/particle_cloud.dart';
import '../../helpers/responsive_test_helper.dart';
import '../../helpers/settings_test_helper.dart';
import '../../helpers/test_app.dart';

/// Scrolls the target into view before tapping it. On a short landscape
/// window the intro and the chapter body scroll, so a blind tap lands on
/// nothing even though the screen works.
Future<void> tapKey(WidgetTester t, String key) async {
  final finder = find.byKey(Key(key));
  await t.ensureVisible(finder);
  await t.pumpAndSettle();
  await t.tap(finder);
  await t.pumpAndSettle();
}

Future<void> _start(WidgetTester t) async {
  await t.pumpWidget(buildTestableWidget(const FootprintStoryScreen(),
      disableAnimations: true));
  await t.pumpAndSettle();
  await tapKey(t, 'story-start');
}

void main() {
  setUp(() async => await setupServiceLocator());

  testWidgets('opens on an intro with a start and a skip', (t) async {
    await t.pumpWidget(buildTestableWidget(const FootprintStoryScreen(),
        disableAnimations: true));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('story-start')), findsOneWidget);
    expect(find.byKey(const Key('story-skip')), findsOneWidget);
  });

  testWidgets('skip goes straight to the result', (t) async {
    await t.pumpWidget(buildTestableWidget(const FootprintStoryScreen(),
        disableAnimations: true));
    await t.pumpAndSettle();
    await tapKey(t, 'story-skip');
    expect(find.byType(FootprintResultScreen), findsOneWidget);
  });

  testWidgets('paging is by button, never by swipe', (t) async {
    await _start(t);
    final view = t.widget<PageView>(find.byType(PageView));
    expect(
      view.physics,
      isA<NeverScrollableScrollPhysics>(),
      reason: 'the RTL edge-back overlay in main.dart eats a forward swipe, '
          'and sliders fight a horizontal PageView for the same drag',
    );
  });

  testWidgets('there is exactly one cloud, above the pages', (t) async {
    await _start(t);
    expect(find.byType(ParticleCloud), findsOneWidget);
  });

  testWidgets('moving a control marks the chapter answered', (t) async {
    await _start(t);
    final state =
        t.state<FootprintStoryScreenState>(find.byType(FootprintStoryScreen));
    expect(state.input.touched, isEmpty);
    await tapKey(t, 'chip-waterSource-1');
    expect(state.input.touched, isNotEmpty);
  });

  testWidgets('accepting the default also counts as an answer', (t) async {
    await _start(t);
    final state =
        t.state<FootprintStoryScreenState>(find.byType(FootprintStoryScreen));
    await tapKey(t, 'confirm-default-water');
    expect(state.input.touched, contains(ChapterKey.water));
  });

  testWidgets('the why line appears only after the chapter is answered',
      (t) async {
    await _start(t);
    expect(
        find.text('Heat and shaking break the bottle wall into fragments. '
            'A bottle left in a hot car sheds about nine times more of the '
            'smallest pieces than a cool one.'),
        findsNothing);
    await tapKey(t, 'confirm-default-water');
    expect(find.textContaining('hot car'), findsOneWidget);
  });

  testWidgets('sliders announce their unit, not a percentage', (t) async {
    await _start(t);
    final slider =
        t.widget<Slider>(find.byKey(const Key('slider-waterBottlesPerDay')));
    expect(slider.semanticFormatterCallback, isNotNull);
    expect(slider.semanticFormatterCallback!(3), contains('bottles'));
  });

  testWidgets('walking every chapter reaches the result', (t) async {
    await _start(t);
    for (var i = 0; i < kChapters.length; i++) {
      await tapKey(t, 'story-next');
    }
    expect(find.byType(FootprintResultScreen), findsOneWidget);
  });

  // Every chapter, every device, both languages.
  for (final device in kAllDevices) {
    // Every shipped locale, not just the template and Arabic: cs, fr and ru
    // all run longer than English, which is how translated text breaks a
    // layout that fitted fine in en.
    for (final locale in const [
      Locale('en'),
      Locale('ar'),
      Locale('cs'),
      Locale('es'),
      Locale('fr'),
      Locale('ru'),
    ]) {
      testWidgets('every chapter fits $device in ${locale.languageCode}',
          (t) async {
        setScreenSize(t, device);
        await t.pumpWidget(buildTestableWidget(const FootprintStoryScreen(),
            locale: locale, disableAnimations: true));
        await t.pumpAndSettle();
        await tapKey(t, 'story-start');
        for (var i = 0; i < kChapters.length - 1; i++) {
          await tapKey(t, 'story-next');
        }
        expect(find.byType(FootprintStoryScreen), findsOneWidget);
      });
    }
  }

  testWidgets('every chapter fits at 200 percent text scale', (t) async {
    setScreenSize(t, kBaseline);
    await t.pumpWidget(buildTestableWidget(const FootprintStoryScreen(),
        textScaleFactor: 2.0, disableAnimations: true));
    await t.pumpAndSettle();
    await tapKey(t, 'story-start');
    for (var i = 0; i < kChapters.length - 1; i++) {
      await tapKey(t, 'story-next');
    }
    expect(find.byType(FootprintStoryScreen), findsOneWidget);
  });
}
