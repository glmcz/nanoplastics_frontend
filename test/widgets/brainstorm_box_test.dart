import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/widgets/brainstorm_box.dart';
import '../helpers/test_app.dart';
import '../helpers/settings_test_helper.dart';

void main() {
  setUp(() async {
    await setupSettingsManager();
  });

  group('BrainstormBox rendering', () {
    testWidgets('displays title', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const BrainstormBox(
          title: 'Share Your Idea',
          username: 'TestUser',
          placeholder: 'Type here...',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Share Your Idea'), findsOneWidget);
    });

    testWidgets('displays placeholder text in text field', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const BrainstormBox(
          title: 'Title',
          username: 'User',
          placeholder: 'Enter your brainstorm idea...',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Enter your brainstorm idea...'), findsOneWidget);
    });

    testWidgets('displays username from props when no saved displayName',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const BrainstormBox(
          title: 'Title',
          username: 'DefaultUser',
          placeholder: 'Placeholder',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('DefaultUser'), findsOneWidget);
    });

    testWidgets('displays saved displayName from SettingsManager',
        (tester) async {
      await setupSettingsManager({'display_name': 'SavedName'});
      await tester.pumpWidget(buildTestableWidget(
        const BrainstormBox(
          title: 'Title',
          username: 'DefaultUser',
          placeholder: 'Placeholder',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('SavedName'), findsOneWidget);
      expect(find.text('DefaultUser'), findsNothing);
    });

    testWidgets('displays submit button with default text', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const BrainstormBox(
          title: 'Title',
          username: 'User',
          placeholder: 'Placeholder',
        ),
      ));
      await tester.pumpAndSettle();

      // The submit button contains an ElevatedButton
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('displays custom submit text when provided', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const BrainstormBox(
          title: 'Title',
          username: 'User',
          placeholder: 'Placeholder',
          submitText: 'Send Now',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Send Now'), findsOneWidget);
    });
  });

  group('BrainstormBox draft persistence', () {
    testWidgets('loads draft from SettingsManager on init', (tester) async {
      await setupSettingsManager({'draft_idea_central_systems': 'My saved draft'});

      await tester.pumpWidget(buildTestableWidget(
        const BrainstormBox(
          title: 'Title',
          username: 'User',
          placeholder: 'Placeholder',
          category: 'central_systems',
        ),
      ));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, equals('My saved draft'));
    });

    testWidgets('does not load draft when category is null', (tester) async {
      await setupSettingsManager({'draft_idea_cat1': 'Draft text'});

      await tester.pumpWidget(buildTestableWidget(
        const BrainstormBox(
          title: 'Title',
          username: 'User',
          placeholder: 'Placeholder',
          category: null,
        ),
      ));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, isEmpty);
    });
  });

  group('BrainstormBox validation', () {
    testWidgets('shows snackbar error when submitting text shorter than 10 chars',
        (tester) async {
      bool callbackCalled = false;

      await tester.pumpWidget(buildTestableWidget(
        BrainstormBox(
          title: 'Title',
          username: 'User',
          placeholder: 'Placeholder',
          onSubmit: (text, attachments) async {
            callbackCalled = true;
          },
        ),
      ));
      await tester.pumpAndSettle();

      // Enter short text
      await tester.enterText(find.byType(TextField), 'Short');
      await tester.pumpAndSettle();

      // Tap submit
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify snackbar appears
      expect(find.byType(SnackBar), findsOneWidget);
      expect(callbackCalled, isFalse);
    });

    testWidgets('does not call onSubmit for text shorter than 10 chars',
        (tester) async {
      int callCount = 0;

      await tester.pumpWidget(buildTestableWidget(
        BrainstormBox(
          title: 'Title',
          username: 'User',
          placeholder: 'Placeholder',
          onSubmit: (text, attachments) async {
            callCount++;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '123456789');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(callCount, equals(0));
    });
  });

  group('BrainstormBox submission', () {
    testWidgets('calls onSubmit callback with trimmed text on valid submit',
        (tester) async {
      String? submittedText;

      await tester.pumpWidget(buildTestableWidget(
        BrainstormBox(
          title: 'Title',
          username: 'User',
          placeholder: 'Placeholder',
          onSubmit: (text, attachments) async {
            submittedText = text;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextField), '  This is a valid brainstorm idea  ');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(submittedText, equals('This is a valid brainstorm idea'));
    });

    testWidgets('clears text field after successful submit', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        BrainstormBox(
          title: 'Title',
          username: 'User',
          placeholder: 'Placeholder',
          onSubmit: (text, attachments) async {},
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextField), 'This is a valid brainstorm idea');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, isEmpty);
    });

    testWidgets('shows success snackbar after successful submit',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        BrainstormBox(
          title: 'Title',
          username: 'User',
          placeholder: 'Placeholder',
          onSubmit: (text, attachments) async {},
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextField), 'This is a valid brainstorm idea');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Success snackbar has pastelMint background
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('shows error snackbar when onSubmit throws', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        BrainstormBox(
          title: 'Title',
          username: 'User',
          placeholder: 'Placeholder',
          onSubmit: (text, attachments) async {
            throw Exception('Server error');
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextField), 'This is a valid brainstorm idea');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Error snackbar should appear
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('does not clear text field when onSubmit throws',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        BrainstormBox(
          title: 'Title',
          username: 'User',
          placeholder: 'Placeholder',
          onSubmit: (text, attachments) async {
            throw Exception('Network error');
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextField), 'This is a valid brainstorm idea');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, isNotEmpty);
    });
  });

  group('BrainstormBox username editing', () {
    testWidgets('tapping username area opens edit dialog', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const BrainstormBox(
          title: 'Title',
          username: 'TestUser',
          placeholder: 'Placeholder',
        ),
      ));
      await tester.pumpAndSettle();

      // Find and tap the InkWell wrapping the username
      await tester.tap(find.text('TestUser'));
      await tester.pumpAndSettle();

      // AlertDialog should appear
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('edit dialog pre-populates with current username',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const BrainstormBox(
          title: 'Title',
          username: 'OriginalUser',
          placeholder: 'Placeholder',
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('OriginalUser'));
      await tester.pumpAndSettle();

      // The dialog's TextField should contain the current username
      final dialogTextFields = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      );
      expect(dialogTextFields, findsOneWidget);

      final dialogTextField = tester.widget<TextField>(dialogTextFields);
      expect(dialogTextField.controller!.text, equals('OriginalUser'));
    });

    testWidgets('canceling edit dialog does not change username',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const BrainstormBox(
          title: 'Title',
          username: 'OriginalUser',
          placeholder: 'Placeholder',
        ),
      ));
      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.text('OriginalUser'));
      await tester.pumpAndSettle();

      // Find Cancel button in dialog and tap it
      final cancelButtons = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextButton),
      );
      // Cancel is the first TextButton
      await tester.tap(cancelButtons.first);
      await tester.pumpAndSettle();

      // Username should be unchanged
      expect(find.text('OriginalUser'), findsOneWidget);
    });
  });
}
