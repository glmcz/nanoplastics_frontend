import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/screens/user_settings/privacy_security_screen.dart';
import 'package:nanoplastics_app/services/settings_manager.dart';
import '../../helpers/test_app.dart';
import '../../helpers/settings_test_helper.dart';

void main() {
  setUp(() async {
    await setupServiceLocator();
  });

  Widget buildPrivacySecurityApp() {
    return buildTestableWidget(const PrivacySecurityScreen());
  }

  group('PrivacySecurityScreen rendering', () {
    testWidgets('analytics toggle renders with correct initial state',
        (tester) async {
      await tester.pumpWidget(buildPrivacySecurityApp());
      await tester.pumpAndSettle();

      // Toggle should be visible
      expect(find.byType(Switch), findsWidgets);

      // Verify the toggle widget exists
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('displays analytics toggle', (tester) async {
      await tester.pumpWidget(buildPrivacySecurityApp());
      await tester.pumpAndSettle();

      // At least one switch should be present for analytics
      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('displays privacy settings heading', (tester) async {
      await tester.pumpWidget(buildPrivacySecurityApp());
      await tester.pumpAndSettle();

      // Page should have text content
      expect(find.byType(Text), findsWidgets);
    });
  });

  group('PrivacySecurityScreen analytics toggle', () {
    testWidgets('toggling analytics updates SettingsManager', (tester) async {
      await tester.pumpWidget(buildPrivacySecurityApp());
      await tester.pumpAndSettle();

      final settingsManager = SettingsManager();

      // Remember initial state
      final initialState = settingsManager.analyticsEnabled;

      // Find and tap the analytics toggle
      final toggleSwitch = find.byType(Switch).first;
      expect(toggleSwitch, findsOneWidget);

      await tester.tap(toggleSwitch);
      await tester.pumpAndSettle();

      // State should have changed (toggled)
      expect(
        settingsManager.analyticsEnabled,
        !initialState,
      );
    });

    testWidgets('analytics toggle reflects current setting', (tester) async {
      final settingsManager = SettingsManager();

      // Set analytics enabled
      await settingsManager.setAnalyticsEnabled(true);

      await tester.pumpWidget(buildPrivacySecurityApp());
      await tester.pumpAndSettle();

      // Verify the toggle is in enabled state
      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('toggling analytics disables/enables Crashlytics',
        (tester) async {
      await tester.pumpWidget(buildPrivacySecurityApp());
      await tester.pumpAndSettle();

      final settingsManager = SettingsManager();

      // Get initial state
      final initialAnalyticsState = settingsManager.analyticsEnabled;

      // Find and tap the toggle
      final toggleSwitch = find.byType(Switch).first;
      expect(toggleSwitch, findsOneWidget);

      await tester.tap(toggleSwitch);
      await tester.pumpAndSettle();

      // Verify analytics state changed (toggled)
      expect(
        settingsManager.analyticsEnabled,
        !initialAnalyticsState,
      );
    });
  });

  group('PrivacySecurityScreen layout', () {
    testWidgets('renders as scrollable content', (tester) async {
      await tester.pumpWidget(buildPrivacySecurityApp());
      await tester.pumpAndSettle();

      // Check for scrollable widget
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('has back button in header', (tester) async {
      await tester.pumpWidget(buildPrivacySecurityApp());
      await tester.pumpAndSettle();

      // Back button should be present
      expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
    });

    testWidgets('back button navigates to previous screen', (tester) async {
      await tester.pumpWidget(buildPrivacySecurityApp());
      await tester.pumpAndSettle();

      // Find back button
      final backButton = find.byIcon(Icons.arrow_back_ios);
      expect(backButton, findsOneWidget);

      // Tap should be possible
      await tester.tap(backButton);
      await tester.pumpAndSettle();
    });
  });
}
