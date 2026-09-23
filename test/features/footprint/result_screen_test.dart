import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/features/footprint/footprint_model.dart';
import 'package:nanoplastics_app/features/footprint/footprint_types.dart';
import 'package:nanoplastics_app/screens/footprint/footprint_result_screen.dart';
import 'package:nanoplastics_app/services/settings_manager.dart';
import 'package:nanoplastics_app/widgets/footprint/charge_panel.dart';
import 'package:nanoplastics_app/widgets/footprint/habit_bar_chart.dart';
import 'package:nanoplastics_app/widgets/footprint/particle_cloud.dart';
import '../../helpers/responsive_test_helper.dart';
import '../../helpers/settings_test_helper.dart';
import '../../helpers/test_app.dart';

FootprintInput answered() => FootprintInput.gulfDefault().copyWith(
    touched: ChapterKey.values.toSet(), prediction: Habit.bottledWater);

Widget screen({FootprintInput? input, bool returning = false}) =>
    FootprintResultScreen(input: input ?? answered(), returning: returning);

Future<void> show(WidgetTester t,
    {Widget? child,
    Locale locale = const Locale('en'),
    double scale = 1.0}) async {
  await t.pumpWidget(buildTestableWidget(child ?? screen(),
      locale: locale, textScaleFactor: scale, disableAnimations: true));
  await t.pumpAndSettle();
}

/// The result screen is a long lazy list, so a widget below the fold has no
/// element until it is scrolled into view.
Future<void> scrollTo(WidgetTester t, Finder target) async {
  await t.scrollUntilVisible(
    target,
    200,
    scrollable: find
        .descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await t.pumpAndSettle();
}

Future<void> scrollToKey(WidgetTester t, String key) =>
    scrollTo(t, find.byKey(Key(key)));

void main() {
  setUp(() async => await setupServiceLocator());

  testWidgets('the headline resolves the prediction against the answer',
      (t) async {
    await show(t);
    expect(find.byKey(const Key('result-headline')), findsOneWidget);
    expect(find.byKey(const Key('result-prediction')), findsOneWidget);
  });

  testWidgets('one cloud per family, each captioned with its floor', (t) async {
    await show(t);
    expect(find.byType(ParticleCloud), findsNWidgets(Family.values.length));
    for (final f in Family.values) {
      expect(find.byKey(Key('floor-caption-${f.name}')), findsOneWidget);
    }
  });

  testWidgets('the open question sits between the clouds', (t) async {
    await show(t);
    expect(find.byKey(const Key('result-open-question')), findsOneWidget);
  });

  testWidgets('no grand total and no percentage anywhere', (t) async {
    await show(t);
    final texts = t
        .widgetList<Text>(find.byType(Text))
        .map((w) => w.data ?? '')
        .join(' ');
    expect(texts, isNot(contains('%')),
        reason: 'summing across size floors would rank habits by microscope');
  });

  testWidgets('unanswered chapters are counted honestly', (t) async {
    await show(t,
        child: screen(
            input: FootprintInput.gulfDefault()
                .copyWith(touched: {ChapterKey.water})));
    final label = t.widget<Text>(find.byKey(const Key('result-touched-count')));
    expect(label.data, contains('1'));
  });

  testWidgets('the count and weight orders genuinely differ', (t) async {
    await show(t);
    await scrollTo(t, find.byType(HabitBarChart));
    final state = t.state<HabitBarChartState>(find.byType(HabitBarChart));
    expect(state.orderedHabits.first, Habit.microwaveMeals);

    await t.tap(find.byKey(const Key('bar-mode-weight')));
    await t.pumpAndSettle();
    final after = t.state<HabitBarChartState>(find.byType(HabitBarChart));
    expect(after.orderedHabits.first, Habit.cuttingBoard);
  });

  testWidgets('bars are logarithmic, so nothing is a hairline', (t) async {
    await show(t);
    await scrollTo(t, find.byType(HabitBarChart));
    final state = t.state<HabitBarChartState>(find.byType(HabitBarChart));
    final lengths = state.debugBarLengths.where((l) => l > 0).toList();
    final smallest = lengths.reduce((a, b) => a < b ? a : b);
    final largest = lengths.reduce((a, b) => a > b ? a : b);
    expect(smallest / largest, greaterThan(0.02),
        reason: 'a linear axis would put this ratio near one billionth');
  });

  testWidgets('every bar carries an icon, a label and its method', (t) async {
    await show(t);
    await scrollTo(t, find.byType(HabitBarChart));
    final state = t.state<HabitBarChartState>(find.byType(HabitBarChart));
    for (final h in state.orderedHabits) {
      expect(find.byKey(Key('bar-icon-${h.name}')), findsOneWidget);
      expect(find.byKey(Key('bar-label-${h.name}')), findsOneWidget);
      expect(find.byKey(Key('bar-tag-${h.name}')), findsOneWidget);
    }
  });

  testWidgets('swaps are substitutions, split into yours and household',
      (t) async {
    await show(t);
    await scrollToKey(t, 'panel-swap');
    expect(find.byKey(const Key('swaps-yours')), findsOneWidget);
    expect(find.byKey(const Key('swaps-household')), findsOneWidget);
    final texts = t
        .widgetList<Text>(find.descendant(
            of: find.byKey(const Key('panel-swap')),
            matching: find.byType(Text)))
        .map((w) => (w.data ?? '').toLowerCase())
        .join(' ');
    expect(texts, contains('could'), reason: 'autonomy-supportive wording');
    expect(texts, isNot(contains('you should')));
  });

  testWidgets('a commitment is stored with what the student wrote', (t) async {
    await show(t);
    await scrollToKey(t, 'commitment-field');
    await t.enterText(find.byKey(const Key('commitment-field')),
        'When I take lunch out, I will use a glass dish');
    await scrollToKey(t, 'commitment-save');
    await t.tap(find.byKey(const Key('commitment-save')));
    await t.pumpAndSettle();
    expect(
        SettingsManager().footprintState['commitment'], contains('glass dish'));
  });

  testWidgets('the charge panel has three stages and a manual control',
      (t) async {
    await show(t);
    await scrollTo(t, find.byType(ChargePanel));
    final state = t.state<ChargePanelState>(find.byType(ChargePanel));
    expect(state.stageCount, 3);
    expect(state.stage, 0);
    await t.tap(find.byKey(const Key('charge-next')));
    await t.pumpAndSettle();
    expect(state.stage, 1);
  });

  testWidgets('the charge panel separates measured from open', (t) async {
    await show(t);
    await scrollToKey(t, 'charge-known');
    expect(find.byKey(const Key('charge-known')), findsOneWidget);
    expect(find.byKey(const Key('charge-not-known')), findsOneWidget);
  });

  testWidgets('say-it-back saves locally and is never graded', (t) async {
    await show(t);
    await scrollToKey(t, 'explain-field');
    await t.enterText(
        find.byKey(const Key('explain-field')), 'Charge makes them stick');
    await scrollToKey(t, 'explain-save');
    await t.tap(find.byKey(const Key('explain-save')));
    await t.pumpAndSettle();
    expect(SettingsManager().footprintState['explanation'], contains('stick'));
    await scrollToKey(t, 'explain-model-answer');
    expect(find.byKey(const Key('explain-model-answer')), findsOneWidget);
    final texts = t
        .widgetList<Text>(find.byType(Text))
        .map((w) => w.data ?? '')
        .join(' ');
    expect(texts.toLowerCase(), isNot(contains('correct')));
  });

  testWidgets('share text carries no percentage and no raw answers', (t) async {
    await show(t);
    final state =
        t.state<FootprintResultScreenState>(find.byType(FootprintResultScreen));
    expect(state.shareText, isNot(contains('%')));
    expect(state.shareText.toLowerCase(), contains('estimate'));
    expect(state.shareText, isNot(contains('microwaveMealsPerWeek')));
  });

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
      testWidgets('result fits $device in ${locale.languageCode}', (t) async {
        setScreenSize(t, device);
        await show(t, locale: locale);
        expect(find.byType(FootprintResultScreen), findsOneWidget);
      });
    }
  }

  testWidgets('result fits at 200 percent text scale', (t) async {
    setScreenSize(t, kBaseline);
    await show(t, scale: 2.0);
    expect(find.byType(FootprintResultScreen), findsOneWidget);
  });
}
