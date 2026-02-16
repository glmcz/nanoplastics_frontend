import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/screens/main_screen.dart';
import 'package:nanoplastics_app/screens/category_detail_new_screen.dart';
import 'package:nanoplastics_app/screens/sources_screen.dart';
import 'package:nanoplastics_app/screens/results_screen.dart';
import 'package:nanoplastics_app/screens/user_settings/user_settings_screen.dart';
import '../helpers/test_app.dart';
import '../helpers/settings_test_helper.dart';

void main() {
  setUp(() async {
    await setupServiceLocator();
  });

  Widget buildMainScreenApp() {
    return buildTestableWidget(const MainScreen());
  }

  group('MainScreen rendering', () {
    testWidgets('displays Human and Planet tabs', (tester) async {
      await tester.pumpWidget(buildMainScreenApp());
      await tester.pumpAndSettle();

      // The hub buttons have labels that are uppercased; may appear in heading + tab
      expect(find.textContaining('HUMAN'), findsWidgets);
      expect(find.textContaining('PLANET'), findsWidgets);
    });

    testWidgets('displays Sources and Results buttons', (tester) async {
      await tester.pumpWidget(buildMainScreenApp());
      await tester.pumpAndSettle();

      expect(find.textContaining('SOURCES'), findsOneWidget);
      expect(find.textContaining('RESULTS'), findsOneWidget);
    });

    testWidgets('displays settings icon', (tester) async {
      await tester.pumpWidget(buildMainScreenApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('displays 6 category cards for human tab', (tester) async {
      await tester.pumpWidget(buildMainScreenApp());
      await tester.pumpAndSettle();

      // Each category card uses a Semantics with button: true and the category title
      // In human tab there should be 6 category cards
      expect(find.byIcon(Icons.psychology_outlined), findsOneWidget);
      expect(find.byIcon(Icons.water_drop_outlined), findsOneWidget);
      expect(find.byIcon(Icons.favorite_outline), findsOneWidget);
      expect(find.byIcon(Icons.child_care_outlined), findsOneWidget);
      expect(find.byIcon(Icons.air_outlined), findsOneWidget);
      expect(find.byIcon(Icons.science_outlined), findsOneWidget);
    });
  });

  group('MainScreen tab switching', () {
    testWidgets('tapping Planet tab shows planet category icons',
        (tester) async {
      await tester.pumpWidget(buildMainScreenApp());
      await tester.pumpAndSettle();

      // Tap Planet tab (use .last to pick the tab button, not the heading)
      await tester.tap(find.textContaining('PLANET').last);
      await tester.pumpAndSettle();

      // Planet tab icons should appear
      expect(find.byIcon(Icons.waves_outlined), findsOneWidget);
      expect(find.byIcon(Icons.cloud_outlined), findsOneWidget);
      expect(find.byIcon(Icons.nature_outlined), findsOneWidget);
      expect(find.byIcon(Icons.explore_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      expect(find.byIcon(Icons.hub_outlined), findsOneWidget);
    });

    testWidgets('tapping Human tab switches back to human categories',
        (tester) async {
      await tester.pumpWidget(buildMainScreenApp());
      await tester.pumpAndSettle();

      // Switch to planet
      await tester.tap(find.textContaining('PLANET').last);
      await tester.pumpAndSettle();

      // Switch back to human
      await tester.tap(find.textContaining('HUMAN').last);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.psychology_outlined), findsOneWidget);
    });
  });

  group('MainScreen navigation', () {
    testWidgets('tapping Sources button navigates to SourcesScreen',
        (tester) async {
      await tester.pumpWidget(buildMainScreenApp());
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('SOURCES'));
      await tester.pumpAndSettle();

      expect(find.byType(SourcesScreen), findsOneWidget);
    });

    testWidgets('tapping Results button navigates to ResultsScreen',
        (tester) async {
      await tester.pumpWidget(buildMainScreenApp());
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('RESULTS'));
      await tester.pumpAndSettle();

      expect(find.byType(ResultsScreen), findsOneWidget);
    });

    testWidgets('tapping settings knob navigates to UserSettingsScreen',
        (tester) async {
      await tester.pumpWidget(buildMainScreenApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.byType(UserSettingsScreen), findsOneWidget);
    });

    testWidgets('tapping a category card navigates to CategoryDetailNewScreen',
        (tester) async {
      await tester.pumpWidget(buildMainScreenApp());
      await tester.pumpAndSettle();

      // Tap the first category card (Central Systems — psychology icon)
      await tester.tap(find.byIcon(Icons.psychology_outlined));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(CategoryDetailNewScreen), findsOneWidget);
    });
  });
}
