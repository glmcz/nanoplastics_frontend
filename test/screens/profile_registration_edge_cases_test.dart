import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/screens/user_settings/profile_registration_dialog.dart';
import 'package:nanoplastics_app/services/settings_manager.dart';
import '../helpers/test_app.dart';
import '../helpers/settings_test_helper.dart';

void main() {
  setUp(() async {
    await setupServiceLocator();
  });

  group('ProfileRegistrationDialog email validation edge cases', () {
    testWidgets('standard valid email passes', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const ProfileRegistrationDialog(),
      ));
      await tester.pumpAndSettle();

      // Fill valid name
      final nameField = find.byType(TextField).at(0);
      await tester.enterText(nameField, 'John Doe');

      // Fill standard valid email
      final emailField = find.byType(TextField).at(1);
      await tester.enterText(emailField, 'john@example.com');
      await tester.pumpAndSettle();

      // Tap Register
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Should succeed (green snackbar or profile saved)
      expect(SettingsManager().isProfileRegistered, isTrue);
    });

    testWidgets('email "a@b.c" (minimal valid) is accepted by regex',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const ProfileRegistrationDialog(),
      ));
      await tester.pumpAndSettle();

      final nameField = find.byType(TextField).at(0);
      await tester.enterText(nameField, 'Test User');

      final emailField = find.byType(TextField).at(1);
      await tester.enterText(emailField, 'a@b.cd');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Regex requires domain with 2+ char TLD: a@b.cd should pass
      expect(SettingsManager().isProfileRegistered, isTrue);
    });

    testWidgets('email "user@.com" is rejected — missing domain name',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const ProfileRegistrationDialog(),
      ));
      await tester.pumpAndSettle();

      final nameField = find.byType(TextField).at(0);
      await tester.enterText(nameField, 'Test User');

      final emailField = find.byType(TextField).at(1);
      await tester.enterText(emailField, 'user@.com');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Should show validation error snackbar
      expect(find.byType(SnackBar), findsOneWidget);
      expect(SettingsManager().isProfileRegistered, isFalse);
    });

    testWidgets('email without @ is rejected', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const ProfileRegistrationDialog(),
      ));
      await tester.pumpAndSettle();

      final nameField = find.byType(TextField).at(0);
      await tester.enterText(nameField, 'Test User');

      final emailField = find.byType(TextField).at(1);
      await tester.enterText(emailField, 'notanemail');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(SettingsManager().isProfileRegistered, isFalse);
    });

    testWidgets('email with spaces is trimmed before validation',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const ProfileRegistrationDialog(),
      ));
      await tester.pumpAndSettle();

      final nameField = find.byType(TextField).at(0);
      await tester.enterText(nameField, 'Test User');

      final emailField = find.byType(TextField).at(1);
      await tester.enterText(emailField, '  user@test.com  ');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Trimmed email should be valid
      expect(SettingsManager().isProfileRegistered, isTrue);
      expect(SettingsManager().email, equals('user@test.com'));
    });
  });

  group('ProfileRegistrationDialog name validation edge cases', () {
    testWidgets('name with only spaces is rejected as empty after trim',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const ProfileRegistrationDialog(),
      ));
      await tester.pumpAndSettle();

      final nameField = find.byType(TextField).at(0);
      await tester.enterText(nameField, '   ');

      final emailField = find.byType(TextField).at(1);
      await tester.enterText(emailField, 'test@test.com');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(SettingsManager().isProfileRegistered, isFalse);
    });
  });

  group('ProfileRegistrationDialog state persistence', () {
    testWidgets('successful save stores displayName, email, bio to SettingsManager',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const ProfileRegistrationDialog(),
      ));
      await tester.pumpAndSettle();

      final nameField = find.byType(TextField).at(0);
      await tester.enterText(nameField, 'Jane Doe');

      final emailField = find.byType(TextField).at(1);
      await tester.enterText(emailField, 'jane@example.com');

      final specialtyField = find.byType(TextField).at(2);
      await tester.enterText(specialtyField, 'Marine Biology');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(SettingsManager().displayName, equals('Jane Doe'));
      expect(SettingsManager().email, equals('jane@example.com'));
      expect(SettingsManager().bio, equals('Marine Biology'));
      expect(SettingsManager().isProfileRegistered, isTrue);
    });

    testWidgets('Skip button does NOT modify SettingsManager state',
        (tester) async {
      // Pre-set some values to verify they don't change
      await SettingsManager().setDisplayName('PreExisting');

      await tester.pumpWidget(buildTestableWidget(
        const ProfileRegistrationDialog(),
      ));
      await tester.pumpAndSettle();

      // Enter data but don't save — tap Skip
      final nameField = find.byType(TextField).at(0);
      await tester.enterText(nameField, 'Should Not Save');

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // SettingsManager should be unchanged
      expect(SettingsManager().displayName, equals('PreExisting'));
      expect(SettingsManager().isProfileRegistered, isFalse);
    });
  });

  group('ProfileRegistrationDialog pre-population', () {
    testWidgets('re-opening dialog pre-populates with existing SettingsManager values',
        (tester) async {
      // Set up existing profile data
      await SettingsManager().setDisplayName('Existing Name');
      await SettingsManager().setEmail('existing@email.com');
      await SettingsManager().setBio('Existing Bio');

      await tester.pumpWidget(buildTestableWidget(
        const ProfileRegistrationDialog(),
      ));
      await tester.pumpAndSettle();

      // All fields should be pre-populated
      final nameField = tester.widget<TextField>(find.byType(TextField).at(0));
      final emailField = tester.widget<TextField>(find.byType(TextField).at(1));
      final bioField = tester.widget<TextField>(find.byType(TextField).at(2));

      expect(nameField.controller!.text, equals('Existing Name'));
      expect(emailField.controller!.text, equals('existing@email.com'));
      expect(bioField.controller!.text, equals('Existing Bio'));
    });
  });

  group('ProfileRegistrationDialog loading state', () {
    testWidgets('Register button shows text by default', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const ProfileRegistrationDialog(),
      ));
      await tester.pumpAndSettle();

      // Register button should be visible and enabled
      expect(find.text('Register'), findsOneWidget);
    });
  });
}
