import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/features/footprint/footprint_model.dart';
import 'package:nanoplastics_app/features/footprint/footprint_types.dart';
import 'package:nanoplastics_app/widgets/footprint/particle_cloud.dart';
import '../../helpers/test_app.dart';

HabitEstimate _h(Habit habit, double n) => HabitEstimate(
      habit: habit,
      family: Family.swallowedSubMicron,
      particlesPerYear: n,
      low: n / 2,
      high: n * 2,
      massMgPerYear: 1,
      method: Method.nta,
      sizeFloorNm: 30,
      tags: const [Tag.measured],
      source: 'test',
    );

void main() {
  final habits = [
    _h(Habit.microwaveMeals, 3.29e13),
    _h(Habit.bottledWater, 1.22e9),
  ];

  Widget cloud({
    bool paused = false,
    VoidCallback? onToggle,
    List<HabitEstimate>? items,
  }) =>
      ParticleCloud(
        habits: items ?? habits,
        semanticLabel: 'about 30 trillion particles a year from two habits',
        paused: paused,
        onTogglePause: onToggle ?? () {},
      );

  testWidgets('the cloud is one semantic node carrying the count', (t) async {
    await t.pumpWidget(buildTestableWidget(cloud()));
    await t.pump();
    expect(
      find.bySemanticsLabel(
          'about 30 trillion particles a year from two habits'),
      findsOneWidget,
    );
  });

  testWidgets('reduce-motion renders without a running ticker', (t) async {
    await t.pumpWidget(
      buildTestableWidget(cloud(), disableAnimations: true),
    );
    await t.pump();
    final state = t.state<ParticleCloudState>(find.byType(ParticleCloud));
    expect(state.isAnimating, isFalse);
  });

  testWidgets('motion runs by default when the OS allows it', (t) async {
    await t.pumpWidget(buildTestableWidget(cloud()));
    await t.pump();
    final state = t.state<ParticleCloudState>(find.byType(ParticleCloud));
    expect(state.isAnimating, isTrue);
  });

  testWidgets('pausing stops the ticker', (t) async {
    await t.pumpWidget(buildTestableWidget(cloud(paused: true)));
    await t.pump();
    final state = t.state<ParticleCloudState>(find.byType(ParticleCloud));
    expect(state.isAnimating, isFalse);
  });

  testWidgets('a pause control is always present and reports taps', (t) async {
    var toggled = 0;
    await t.pumpWidget(buildTestableWidget(cloud(onToggle: () => toggled++)));
    await t.pump();
    await t.tap(find.byKey(const Key('cloud-pause')));
    expect(toggled, 1);
  });

  testWidgets('each habit gets its own shape, not just its own colour',
      (t) async {
    await t.pumpWidget(buildTestableWidget(cloud(paused: true)));
    await t.pump();
    final state = t.state<ParticleCloudState>(find.byType(ParticleCloud));
    expect(state.debugDotShapes.length, habits.length,
        reason: 'two habits must not share a shape');
  });

  testWidgets('dot count is capped and the caption states the scale',
      (t) async {
    await t.pumpWidget(buildTestableWidget(cloud(paused: true)));
    await t.pump();
    final state = t.state<ParticleCloudState>(find.byType(ParticleCloud));
    expect(state.debugDotCount, lessThanOrEqualTo(ParticleCloudState.maxDots));
    expect(find.byKey(const Key('cloud-scale-caption')), findsOneWidget);
  });

  testWidgets('reduce-motion also lowers the dot budget', (t) async {
    await t.pumpWidget(
      buildTestableWidget(cloud(), disableAnimations: true),
    );
    await t.pump();
    final state = t.state<ParticleCloudState>(find.byType(ParticleCloud));
    expect(
        state.debugDotCount, lessThanOrEqualTo(ParticleCloudState.reducedDots));
  });

  testWidgets('a habit with a tiny share still gets at least one dot',
      (t) async {
    await t.pumpWidget(buildTestableWidget(cloud(
      paused: true,
      items: [
        _h(Habit.microwaveMeals, 3.29e13),
        _h(Habit.seafood, 3), // nine orders smaller
      ],
    )));
    await t.pump();
    final state = t.state<ParticleCloudState>(find.byType(ParticleCloud));
    expect(state.debugDotShapes.length, 2,
        reason: 'a small habit must not vanish from the picture');
  });

  testWidgets('an empty list renders without dots and without throwing',
      (t) async {
    await t.pumpWidget(buildTestableWidget(cloud(paused: true, items: const [])));
    await t.pump();
    final state = t.state<ParticleCloudState>(find.byType(ParticleCloud));
    expect(state.debugDotCount, 0);
  });

  testWidgets('renders at 375x667 in Arabic without overflow', (t) async {
    t.view.physicalSize = const Size(375, 667);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      buildTestableWidget(cloud(paused: true), locale: const Locale('ar')),
    );
    await t.pump();
    expect(find.byType(ParticleCloud), findsOneWidget);
  });
}
