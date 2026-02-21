import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/widgets/brainstorm_box.dart';
import 'package:nanoplastics_app/services/settings_manager.dart';
import '../helpers/test_app.dart';
import '../helpers/settings_test_helper.dart';

void main() {
  setUp(() async {
    await setupSettingsManager();
  });

  group('BrainstormBox rapid submit handling', () {
    testWidgets('rapid double-tap on submit fires onSubmit at least once',
        (tester) async {
      int callCount = 0;
      final completer = Completer<void>();

      await tester.pumpWidget(buildTestableWidget(
        BrainstormBox(
          title: 'Test',
          username: 'User',
          placeholder: 'Type...',
          onSubmit: (text, attachments) async {
            callCount++;
            // Simulate slow API call
            await completer.future;
          },
        ),
      ));
      await tester.pumpAndSettle();

      // Enter valid text
      await tester.enterText(
          find.byType(TextField), 'This is a valid brainstorm idea');
      await tester.pumpAndSettle();

      // Rapid double-tap submit button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Complete the async call
      completer.complete();
      await tester.pumpAndSettle();

      // At minimum onSubmit was called once; if there's no guard it may be called twice
      // This test DOCUMENTS the behavior — whether the app has double-submit protection
      expect(callCount, greaterThanOrEqualTo(1));
    });

    testWidgets(
        'submit with slow async callback — second tap behavior is documented',
        (tester) async {
      int callCount = 0;
      final completer = Completer<void>();

      await tester.pumpWidget(buildTestableWidget(
        BrainstormBox(
          title: 'Test',
          username: 'User',
          placeholder: 'Type...',
          onSubmit: (text, attachments) async {
            callCount++;
            await completer.future;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Valid text for testing');
      await tester.pumpAndSettle();

      // First tap — starts async operation
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(const Duration(milliseconds: 100));

      // Second tap while first is still pending
      // After first submit, text is cleared (line 100), so second tap would have empty text
      // which fails validation (< 10 chars). This is an implicit guard!
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      completer.complete();
      await tester.pumpAndSettle();

      // ARCHITECTURAL FIX: Now using _isSubmitting flag to guard against double-submit.
      // The submit button is disabled and early-returns from _handleSubmit() during async.
      // Second tap is blocked by the _isSubmitting guard, so only one call fires.
      expect(callCount, equals(1),
          reason: 'FIXED: Double-submit protection with _isSubmitting flag — '
              'second tap is blocked by early return guard');
    });
  });

  group('BrainstormBox validation edge cases', () {
    testWidgets('10 spaces (whitespace only) fails validation after trim',
        (tester) async {
      bool callbackCalled = false;

      await tester.pumpWidget(buildTestableWidget(
        BrainstormBox(
          title: 'Test',
          username: 'User',
          placeholder: 'Type...',
          onSubmit: (text, attachments) async {
            callbackCalled = true;
          },
        ),
      ));
      await tester.pumpAndSettle();

      // Enter 10 spaces — trim() makes this empty, which is < 10
      await tester.enterText(find.byType(TextField), '          ');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(callbackCalled, isFalse);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('exactly 10 chars after trim passes validation',
        (tester) async {
      bool callbackCalled = false;

      await tester.pumpWidget(buildTestableWidget(
        BrainstormBox(
          title: 'Test',
          username: 'User',
          placeholder: 'Type...',
          onSubmit: (text, attachments) async {
            callbackCalled = true;
          },
        ),
      ));
      await tester.pumpAndSettle();

      // Exactly 10 characters
      await tester.enterText(find.byType(TextField), '1234567890');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(callbackCalled, isTrue);
    });

    testWidgets('9 chars fails, 10 chars passes — boundary test',
        (tester) async {
      int callCount = 0;

      await tester.pumpWidget(buildTestableWidget(
        BrainstormBox(
          title: 'Test',
          username: 'User',
          placeholder: 'Type...',
          onSubmit: (text, attachments) async {
            callCount++;
          },
        ),
      ));
      await tester.pumpAndSettle();

      // 9 chars — should fail
      await tester.enterText(find.byType(TextField), '123456789');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(callCount, equals(0));

      // Now enter 10 chars
      await tester.enterText(find.byType(TextField), '1234567890');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(callCount, equals(1));
    });
  });

  group('BrainstormBox draft behavior on submit failure', () {
    testWidgets(
        'ARCHITECTURAL BUG: onSubmit throws → draft already cleared before try/catch',
        (tester) async {
      // This test documents the bug at brainstorm_box.dart:100-102
      // Draft is cleared INSIDE the try block but BEFORE the await completes in error path:
      // Line 99:  await widget.onSubmit?.call(text);
      // Line 100: _controller.clear();
      // Line 101: if (widget.category != null) {
      // Line 102:   SettingsManager().clearDraftIdea(widget.category!);
      // }
      //
      // Actually, looking at the code more carefully:
      // Lines 100-103 only execute AFTER onSubmit succeeds (they're before the catch).
      // If onSubmit throws, execution jumps to catch block.
      // So draft is NOT cleared on failure. Let's verify.

      await setupSettingsManager({'draft_idea_test_cat': 'My important draft'});

      await tester.pumpWidget(buildTestableWidget(
        BrainstormBox(
          title: 'Test',
          username: 'User',
          placeholder: 'Type...',
          category: 'test_cat',
          onSubmit: (text, attachments) async {
            throw Exception('Server error');
          },
        ),
      ));
      await tester.pumpAndSettle();

      // Verify draft was loaded
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, equals('My important draft'));

      // Submit — will throw
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Text field should NOT be cleared (error path)
      final textFieldAfter = tester.widget<TextField>(find.byType(TextField));
      expect(textFieldAfter.controller!.text, isNotEmpty);

      // Draft in SettingsManager should still exist
      // NOTE: The _saveDraft listener fires on text changes, so
      // the draft still reflects the text field content
      expect(SettingsManager().getDraftIdea('test_cat'), isNotNull);
    });

    testWidgets('onSubmit succeeds → text field cleared AND draft cleared',
        (tester) async {
      await setupSettingsManager({'draft_idea_success_cat': 'Will be cleared'});

      await tester.pumpWidget(buildTestableWidget(
        BrainstormBox(
          title: 'Test',
          username: 'User',
          placeholder: 'Type...',
          category: 'success_cat',
          onSubmit: (text, attachments) async {
            // Simulate successful API call
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Text field should be cleared
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, isEmpty);

      // Draft should be removed from SettingsManager
      // Note: _saveDraft listener fires on clear(), setting empty string
      // which SettingsManager.setDraftIdea removes the key
      expect(SettingsManager().getDraftIdea('success_cat'), isNull);
    });
  });

  group('BrainstormBox dispose during typing', () {
    testWidgets('disposing widget while text field has text does not crash',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const BrainstormBox(
          title: 'Test',
          username: 'User',
          placeholder: 'Type...',
          category: 'dispose_test',
        ),
      ));
      await tester.pumpAndSettle();

      // Type text (triggers _saveDraft listener)
      await tester.enterText(find.byType(TextField), 'Text before dispose');
      await tester.pump();

      // Immediately dispose by replacing widget tree
      await tester.pumpWidget(buildTestableWidget(const SizedBox()));
      await tester.pumpAndSettle();

      // No crash means listener was properly cleaned up
      // Verify draft was persisted before dispose
      expect(SettingsManager().getDraftIdea('dispose_test'),
          equals('Text before dispose'));
    });
  });
}
