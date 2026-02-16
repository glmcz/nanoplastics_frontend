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

  group('BrainstormBox disposal and cleanup', () {
    testWidgets('dispose does not crash — listener removed before controller disposed',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const BrainstormBox(
          title: 'Test',
          username: 'User',
          placeholder: 'Type...',
          category: 'test_category',
        ),
      ));
      await tester.pumpAndSettle();

      // Type something to trigger listener
      await tester.enterText(find.byType(TextField), 'Some text here');
      await tester.pumpAndSettle();

      // Replace widget tree — forces dispose of BrainstormBox
      await tester.pumpWidget(buildTestableWidget(
        const SizedBox(),
      ));
      await tester.pumpAndSettle();

      // If we get here without crash, listener was properly removed before dispose
    });

    testWidgets('widget with null category: _saveDraft does not write to SharedPreferences',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const BrainstormBox(
          title: 'Test',
          username: 'User',
          placeholder: 'Type...',
          category: null,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Typed text');
      await tester.pumpAndSettle();

      // With null category, no draft should be saved
      expect(SettingsManager().getDraftIdea('null'), isNull);
    });
  });

  group('BrainstormBox category isolation', () {
    testWidgets('different categories load different drafts', (tester) async {
      await setupSettingsManager({
        'draft_idea_category_a': 'Draft for A',
        'draft_idea_category_b': 'Draft for B',
      });

      // Mount BrainstormBox for category A (use key to force distinct state)
      await tester.pumpWidget(buildTestableWidget(
        const BrainstormBox(
          key: ValueKey('cat_a'),
          title: 'Test',
          username: 'User',
          placeholder: 'Type...',
          category: 'category_a',
        ),
      ));
      await tester.pumpAndSettle();

      final textFieldA = tester.widget<TextField>(find.byType(TextField));
      expect(textFieldA.controller!.text, equals('Draft for A'));

      // Now mount BrainstormBox for category B (different key forces new State)
      await tester.pumpWidget(buildTestableWidget(
        const BrainstormBox(
          key: ValueKey('cat_b'),
          title: 'Test',
          username: 'User',
          placeholder: 'Type...',
          category: 'category_b',
        ),
      ));
      await tester.pumpAndSettle();

      final textFieldB = tester.widget<TextField>(find.byType(TextField));
      expect(textFieldB.controller!.text, equals('Draft for B'));
    });

    testWidgets('typing in one category does not affect another category draft',
        (tester) async {
      // Mount BrainstormBox for category A and type
      await tester.pumpWidget(buildTestableWidget(
        const BrainstormBox(
          title: 'Test',
          username: 'User',
          placeholder: 'Type...',
          category: 'cat_x',
        ),
      ));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Only for cat_x');
      await tester.pumpAndSettle();

      // Verify cat_x draft saved, cat_y has nothing
      expect(SettingsManager().getDraftIdea('cat_x'), equals('Only for cat_x'));
      expect(SettingsManager().getDraftIdea('cat_y'), isNull);
    });
  });

  group('BrainstormBox username editing side effects', () {
    testWidgets('_saveUsername persists to SettingsManager.displayName',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const BrainstormBox(
          title: 'Test',
          username: 'DefaultUser',
          placeholder: 'Type...',
        ),
      ));
      await tester.pumpAndSettle();

      // Tap username to open edit dialog
      await tester.tap(find.text('DefaultUser'));
      await tester.pumpAndSettle();

      // Clear and type new name
      final dialogTextField = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      );
      await tester.enterText(dialogTextField, 'NewUsername');
      await tester.pumpAndSettle();

      // Find and tap Save button (second TextButton in dialog)
      final dialogButtons = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextButton),
      );
      await tester.tap(dialogButtons.last);
      await tester.pumpAndSettle();

      // Verify SettingsManager was updated
      expect(SettingsManager().displayName, equals('NewUsername'));
      // Verify UI shows new username
      expect(find.text('NewUsername'), findsOneWidget);
    });

    testWidgets('cancel dialog does not modify SettingsManager',
        (tester) async {
      await setupSettingsManager({'display_name': 'OriginalName'});

      await tester.pumpWidget(buildTestableWidget(
        const BrainstormBox(
          title: 'Test',
          username: 'Fallback',
          placeholder: 'Type...',
        ),
      ));
      await tester.pumpAndSettle();

      // Tap username to open edit dialog
      await tester.tap(find.text('OriginalName'));
      await tester.pumpAndSettle();

      // Modify text in dialog
      final dialogTextField = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      );
      await tester.enterText(dialogTextField, 'ChangedName');

      // Tap Cancel button (first TextButton)
      final dialogButtons = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextButton),
      );
      await tester.tap(dialogButtons.first);
      await tester.pumpAndSettle();

      // SettingsManager should still have original name
      expect(SettingsManager().displayName, equals('OriginalName'));
    });
  });
}
