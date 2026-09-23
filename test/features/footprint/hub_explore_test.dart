import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/screens/explore_screen.dart';
import 'package:nanoplastics_app/screens/main_screen.dart';
import 'package:nanoplastics_app/services/settings_manager.dart';
import 'package:nanoplastics_app/widgets/nanosolve_logo.dart';
import '../../helpers/responsive_test_helper.dart';
import '../../helpers/settings_test_helper.dart';
import '../../helpers/test_app.dart';

void main() {
  testWidgets('the hub offers an Explore entry', (t) async {
    await setupServiceLocator({'explore_seen': true});
    await t.pumpWidget(buildTestableWidget(const MainScreen()));
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('hub-button-explore')), findsOneWidget);
  });

  testWidgets('the four quadrants are untouched', (t) async {
    await setupServiceLocator({'explore_seen': true});
    await t.pumpWidget(buildTestableWidget(const MainScreen()));
    await t.pumpAndSettle();
    for (final q in ['human', 'planet', 'sources', 'results']) {
      expect(find.byKey(ValueKey('hub-button-$q')), findsOneWidget,
          reason: 'quadrant $q must survive the Explore addition');
    }
  });

  testWidgets('tapping Explore opens the Explore screen', (t) async {
    await setupServiceLocator({'explore_seen': true});
    await t.pumpWidget(buildTestableWidget(const MainScreen()));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const ValueKey('hub-button-explore')));
    await t.pumpAndSettle();
    expect(find.byType(ExploreScreen), findsOneWidget);
  });

  testWidgets('a new install is never routed away from the hub', (t) async {
    // Pushing a screen the student did not ask for, over the one they
    // launched into, is the kind of thing people close the app over. The
    // tool is advertised with a dot instead.
    await setupServiceLocator({'explore_seen': false});
    await t.pumpWidget(buildTestableWidget(const MainScreen()));
    await t.pumpAndSettle();
    expect(find.byType(ExploreScreen), findsNothing);
  });

  testWidgets('an unopened tool is marked new, and the mark clears', (t) async {
    await setupServiceLocator({'explore_seen': false});
    await t.pumpWidget(buildTestableWidget(const MainScreen()));
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('hub-explore-new-dot')), findsOneWidget);

    await t.tap(find.byKey(const ValueKey('hub-button-explore')));
    await t.pumpAndSettle();
    expect(find.byType(ExploreScreen), findsOneWidget);
    expect(SettingsManager().hasSeenExplore, isTrue);

    // pageBack looks for a Cupertino back button, which this screen's shared
    // header does not use. Pop the route directly instead.
    Navigator.of(t.element(find.byType(ExploreScreen))).pop();
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('hub-explore-new-dot')), findsNothing);
  });

  testWidgets('an already-opened tool carries no mark', (t) async {
    await setupServiceLocator({'explore_seen': true});
    await t.pumpWidget(buildTestableWidget(const MainScreen()));
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('hub-explore-new-dot')), findsNothing);
  });

  for (final device in kAllDevices) {
    testWidgets('hub with Explore fits $device', (t) async {
      await setupServiceLocator({'explore_seen': true});
      setScreenSize(t, device);
      await t.pumpWidget(buildTestableWidget(const MainScreen()));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('hub-button-explore')), findsOneWidget);
    });
  }

  group('the Explore entry never covers the wordmark', () {
    // The pill used to sit in a Stack on top of the logo. NanosolveLogo is
    // four times as wide as it is tall, so on a 375pt screen it leaves about
    // 40pt free at each side while the pill needs 44pt to clear the minimum
    // touch target. Overlap was unavoidable, not a tuning problem.
    for (final size in const [Size(375, 667), Size(320, 568)]) {
      testWidgets('logo and Explore pill do not overlap at ${size.width}pt',
          (t) async {
        await setupServiceLocator({'explore_seen': true});
        t.view.physicalSize = size;
        t.view.devicePixelRatio = 1.0;
        addTearDown(t.view.reset);

        await t.pumpWidget(buildTestableWidget(const MainScreen()));
        await t.pumpAndSettle();

        final logo = find.byType(NanosolveLogo).first;
        final pill = find.byKey(const ValueKey('hub-button-explore'));
        expect(pill, findsOneWidget);

        final logoRect = t.getRect(logo);
        final pillRect = t.getRect(pill);
        expect(
          logoRect.overlaps(pillRect),
          isFalse,
          reason: 'Explore sits on the NanoSolve wordmark. '
              'logo=$logoRect pill=$pillRect',
        );

        // Reserving a slot for the pill without mirroring it on the other
        // side would clear the overlap by pushing the wordmark off centre,
        // which trades one visual defect for another.
        expect(
          logoRect.center.dx,
          closeTo(size.width / 2, 1.0),
          reason: 'the wordmark is off centre: logo=$logoRect',
        );
      });
    }
  });
}
