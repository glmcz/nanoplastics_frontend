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

  Widget buildDialogInApp({VoidCallback? onProfileShared}) {
    return buildTestableWidget(
      Builder(
        builder: (context) => ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => ProfileRegistrationDialog(
                onProfileShared: onProfileShared,
              ),
            );
          },
          child: const Text('Open Dialog'),
        ),
      ),
    );
  }

  Future<void> openDialog(WidgetTester tester,
      {VoidCallback? onProfileShared}) async {
    await tester.pumpWidget(buildDialogInApp(
      onProfileShared: onProfileShared,
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();
  }

  group('ProfileRegistrationDialog rendering', () {
    testWidgets('displays "Join the Community" title', (tester) async {
      await openDialog(tester);
      expect(find.text('Join the Community'), findsOneWidget);
    });

    testWidgets('displays 3 text fields: name, email, specialty',
        (tester) async {
      await openDialog(tester);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Specialty (Optional)'), findsOneWidget);
    });

    testWidgets('displays Skip and Register buttons', (tester) async {
      await openDialog(tester);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('pre-populates fields from SettingsManager', (tester) async {
      await setupServiceLocator({
        'display_name': 'Pre Name',
        'email': 'pre@test.com',
        'bio': 'Pre Specialty',
      });

      await openDialog(tester);

      // Find TextFields inside the dialog
      final textFields = find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(TextField),
      );
      // There are 3 fields
      expect(textFields, findsNWidgets(3));

      final nameField = tester.widget<TextField>(textFields.at(0));
      final emailField = tester.widget<TextField>(textFields.at(1));
      final specialtyField = tester.widget<TextField>(textFields.at(2));

      expect(nameField.controller!.text, equals('Pre Name'));
      expect(emailField.controller!.text, equals('pre@test.com'));
      expect(specialtyField.controller!.text, equals('Pre Specialty'));
    });
  });

  group('ProfileRegistrationDialog validation', () {
    testWidgets('shows error snackbar when name is empty', (tester) async {
      await openDialog(tester);

      // Leave name empty, enter email
      final textFields = find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(TextField),
      );
      await tester.enterText(textFields.at(1), 'test@email.com');

      // Tap Register
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your full name'), findsOneWidget);
    });

    testWidgets('shows error snackbar when email is empty', (tester) async {
      await openDialog(tester);

      final textFields = find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(TextField),
      );
      await tester.enterText(textFields.at(0), 'John Doe');

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email address'), findsOneWidget);
    });

    testWidgets('shows error snackbar for invalid email format',
        (tester) async {
      await openDialog(tester);

      final textFields = find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(TextField),
      );
      await tester.enterText(textFields.at(0), 'John Doe');
      await tester.enterText(textFields.at(1), 'notanemail');

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('invalid emails fail: "@domain.com"', (tester) async {
      await openDialog(tester);

      final textFields = find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(TextField),
      );
      await tester.enterText(textFields.at(0), 'John');
      await tester.enterText(textFields.at(1), '@domain.com');

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });
  });

  group('ProfileRegistrationDialog submission', () {
    testWidgets('saves name, email, specialty to SettingsManager on valid submit',
        (tester) async {
      bool callbackCalled = false;

      await openDialog(tester, onProfileShared: () {
        callbackCalled = true;
      });

      final textFields = find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(TextField),
      );
      await tester.enterText(textFields.at(0), 'Jane Doe');
      await tester.enterText(textFields.at(1), 'jane@example.com');
      await tester.enterText(textFields.at(2), 'Marine Biology');

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      final settings = SettingsManager();
      expect(settings.displayName, equals('Jane Doe'));
      expect(settings.email, equals('jane@example.com'));
      expect(settings.bio, equals('Marine Biology'));
      expect(settings.isProfileRegistered, isTrue);
      expect(callbackCalled, isTrue);
    });

    testWidgets('shows success snackbar on save', (tester) async {
      await openDialog(tester, onProfileShared: () {});

      final textFields = find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(TextField),
      );
      await tester.enterText(textFields.at(0), 'Jane Doe');
      await tester.enterText(textFields.at(1), 'jane@example.com');

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Profile registered successfully!'), findsOneWidget);
    });
  });

  group('ProfileRegistrationDialog skip', () {
    testWidgets('tapping Skip closes dialog without saving', (tester) async {
      await openDialog(tester);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.text('Join the Community'), findsNothing);

      // Settings should not be changed
      expect(SettingsManager().isProfileRegistered, isFalse);
    });
  });
}
