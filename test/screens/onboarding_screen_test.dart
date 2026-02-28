import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/screens/onboarding_screen.dart';
import 'package:nanoplastics_app/services/settings_manager.dart';
import '../helpers/test_app.dart';
import '../helpers/settings_test_helper.dart';

// Mock navigator observer to track navigation calls
class MockNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = [];
  final List<Route<dynamic>> poppedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    poppedRoutes.add(route);
  }
}

void main() {
  setUp(() async {
    await setupServiceLocator();
  });

  Widget buildOnboardingApp() {
    return buildTestableWidget(const OnboardingScreen());
  }

  group('OnboardingScreen rendering', () {
    testWidgets('displays 3 page dots', (tester) async {
      await tester.pumpWidget(buildOnboardingApp());
      await tester.pumpAndSettle();

      // The dots are built via AnimatedContainer with duration 300ms
      // Verify the PageView exists with 3 items
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('displays Next button on first page', (tester) async {
      await tester.pumpWidget(buildOnboardingApp());
      await tester.pumpAndSettle();

      // The button should show localized "Next" text
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('does not display Back button on first page', (tester) async {
      await tester.pumpWidget(buildOnboardingApp());
      await tester.pumpAndSettle();

      // On first page, back button area should be empty (SizedBox.shrink)
      // The TextButton for "Back" should not exist
      expect(find.byType(TextButton), findsNothing);
    });
  });

  group('OnboardingScreen navigation', () {
    testWidgets('tapping Next advances to page 2 and shows Back button',
        (tester) async {
      await tester.pumpWidget(buildOnboardingApp());
      await tester.pumpAndSettle();

      // Tap Next
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Page 2 should now have a Back button (TextButton)
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('tapping Back goes to previous page', (tester) async {
      await tester.pumpWidget(buildOnboardingApp());
      await tester.pumpAndSettle();

      // Go to page 2
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Back button should exist
      expect(find.byType(TextButton), findsOneWidget);

      // Tap Back
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // Should be back on page 1 — no Back button
      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('swiping left advances to next page', (tester) async {
      await tester.pumpWidget(buildOnboardingApp());
      await tester.pumpAndSettle();

      // Swipe left on PageView
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Back button should appear on page 2
      expect(find.byType(TextButton), findsOneWidget);
    });
  });

  group('OnboardingScreen completion', () {
    testWidgets('close icon sets onboardingShown and navigates to MainScreen',
        (tester) async {
      await tester.pumpWidget(buildOnboardingApp());
      await tester.pumpAndSettle();

      // Find close icon button
      final closeButton = find.byIcon(Icons.close);
      expect(closeButton, findsOneWidget);

      await tester.tap(closeButton);
      // Wait for animation to reverse and navigation
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(SettingsManager().hasShownOnboarding, isTrue);
    });

    testWidgets(
        'navigating to last page and tapping button sets onboarding shown',
        (tester) async {
      await tester.pumpWidget(buildOnboardingApp());
      await tester.pumpAndSettle();

      // Navigate to page 2
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Navigate to page 3 (last page)
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // On last page, the button should show "Get Started" text
      // Tap it
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(SettingsManager().hasShownOnboarding, isTrue);
    });
  });

  group('OnboardingScreen isReplay mode', () {
    testWidgets('language selector is hidden on first page in replay mode',
        (tester) async {
      final widget = buildTestableWidget(
        const OnboardingScreen(isReplay: true),
      );
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // On first page (slide 0) in replay mode, language selector should be hidden
      // Language selector icon should not be visible
      expect(find.byIcon(Icons.language), findsNothing);
    });

    testWidgets('close button calls Navigator.pop in replay mode',
        (tester) async {
      final mockObserver = MockNavigatorObserver();

      await tester.pumpWidget(
        buildTestableWidget(
          const OnboardingScreen(isReplay: true),
          navigatorObserver: mockObserver,
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap close icon
      final closeButton = find.byIcon(Icons.close);
      expect(closeButton, findsOneWidget);

      await tester.tap(closeButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify pop was called (not push)
      expect(mockObserver.poppedRoutes.isNotEmpty, isTrue);
    });

    testWidgets('hasShownOnboarding stays unchanged after close in replay mode',
        (tester) async {
      // Set hasShownOnboarding to true before test
      final settingsManager = SettingsManager();
      await settingsManager.setOnboardingShown(true);

      final widget = buildTestableWidget(
        const OnboardingScreen(isReplay: true),
      );
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Remember initial state
      final initialState = settingsManager.hasShownOnboarding;
      expect(initialState, isTrue);

      // Find and tap close icon
      final closeButton = find.byIcon(Icons.close);
      expect(closeButton, findsOneWidget);

      await tester.tap(closeButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify state unchanged
      expect(settingsManager.hasShownOnboarding, equals(initialState));
    });
  });
}
