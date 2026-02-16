import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/screens/solvers_leaderboard_screen.dart';
import 'package:nanoplastics_app/screens/user_settings/profile_registration_dialog.dart';
import '../helpers/test_app.dart';
import '../helpers/settings_test_helper.dart';

void main() {
  group('SolversLeaderboardScreen - unregistered user', () {
    setUp(() async {
      // Empty display_name and email → unregistered
      await setupServiceLocator();
    });

    testWidgets('shows restricted access view when user has no email/name',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const SolversLeaderboardScreen(),
      ));
      await tester.pumpAndSettle();

      // Should show lock icon for restricted access
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('shows "Register Now" button', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const SolversLeaderboardScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.app_registration), findsOneWidget);
    });

    testWidgets('tapping "Register Now" opens ProfileRegistrationDialog',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const SolversLeaderboardScreen(),
      ));
      await tester.pumpAndSettle();

      // Tap the register button
      await tester.tap(find.byIcon(Icons.app_registration));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileRegistrationDialog), findsOneWidget);
    });
  });

  group('SolversLeaderboardScreen - registered user', () {
    setUp(() async {
      await setupServiceLocator({
        'display_name': 'John Doe',
        'email': 'john@example.com',
      });
    });

    testWidgets('does not show restricted access view when registered',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const SolversLeaderboardScreen(),
      ));
      await tester.pumpAndSettle();

      // Registered users should not see lock icon
      expect(find.byIcon(Icons.lock), findsNothing);
      // Should not see the register button
      expect(find.byIcon(Icons.app_registration), findsNothing);
    });
  });
}
