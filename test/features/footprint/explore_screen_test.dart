import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/screens/explore_screen.dart';
import '../../helpers/responsive_test_helper.dart';
import '../../helpers/settings_test_helper.dart';
import '../../helpers/test_app.dart';

void main() {
  setUp(() async => await setupServiceLocator());

  testWidgets('lists the footprint card', (t) async {
    await t.pumpWidget(buildTestableWidget(const ExploreScreen()));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('explore-card-footprint')), findsOneWidget);
  });

  testWidgets('the footprint card is a labelled, tappable semantics node',
      (t) async {
    await t.pumpWidget(buildTestableWidget(const ExploreScreen()));
    await t.pumpAndSettle();
    final node =
        t.getSemantics(find.byKey(const Key('explore-card-footprint')));
    expect(node.label, isNotEmpty);
    expect(node.flagsCollection.isButton, isTrue);
  });

  testWidgets('first run offers a way out', (t) async {
    await t
        .pumpWidget(buildTestableWidget(const ExploreScreen(firstRun: true)));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('explore-skip')), findsOneWidget);
  });

  testWidgets('a normal visit has no skip control', (t) async {
    await t.pumpWidget(buildTestableWidget(const ExploreScreen()));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('explore-skip')), findsNothing);
  });

  // Every device in the project's matrix, in both languages. Overflow throws
  // during pump, so a clean pump is the assertion.
  for (final device in kAllDevices) {
    for (final locale in const [Locale('en'), Locale('ar')]) {
      testWidgets('no overflow on $device in ${locale.languageCode}',
          (t) async {
        setScreenSize(t, device);
        await t.pumpWidget(
          buildTestableWidget(const ExploreScreen(), locale: locale),
        );
        await t.pumpAndSettle();
        expect(find.byType(ExploreScreen), findsOneWidget);
      });
    }
  }

  testWidgets('no overflow at 200 percent text scale', (t) async {
    setScreenSize(t, kTinyPhone);
    await t.pumpWidget(buildTestableWidget(
      const ExploreScreen(),
      textScaleFactor: 2.0,
    ));
    await t.pumpAndSettle();
    expect(find.byType(ExploreScreen), findsOneWidget);
  });
}
