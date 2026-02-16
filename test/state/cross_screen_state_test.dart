import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/widgets/brainstorm_box.dart';
import 'package:nanoplastics_app/services/settings_manager.dart';
import 'package:nanoplastics_app/models/category_detail_data.dart';
import 'package:nanoplastics_app/l10n/app_localizations.dart';
import '../helpers/test_app.dart';
import '../helpers/settings_test_helper.dart';

void main() {
  setUp(() async {
    await setupSettingsManager();
  });

  group('Profile data propagation to BrainstormBox', () {
    testWidgets(
        'BrainstormBox on NEW mount reads updated username from SettingsManager',
        (tester) async {
      // Initially no display name — BrainstormBox should show fallback
      await tester.pumpWidget(buildTestableWidget(
        const BrainstormBox(
          title: 'Test',
          username: 'FallbackUser',
          placeholder: 'Type...',
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('FallbackUser'), findsOneWidget);

      // Simulate profile registration by updating SettingsManager
      await SettingsManager().setDisplayName('RegisteredUser');

      // Dispose old widget first (navigate away)
      await tester.pumpWidget(buildTestableWidget(const SizedBox()));
      await tester.pumpAndSettle();

      // Re-mount BrainstormBox with a different key to force new State
      await tester.pumpWidget(buildTestableWidget(
        const BrainstormBox(
          key: ValueKey('remounted'),
          title: 'Test',
          username: 'FallbackUser',
          placeholder: 'Type...',
        ),
      ));
      await tester.pumpAndSettle();

      // New mount should read updated displayName from SettingsManager
      expect(find.text('RegisteredUser'), findsOneWidget);
      expect(find.text('FallbackUser'), findsNothing);
    });

    testWidgets(
        'FIXED: BrainstormBox mounted reflects username changes from SettingsManager via listener',
        (tester) async {
      // This test VERIFIES the architectural fix:
      // BrainstormBox now subscribes to SettingsManager.displayName changes via listener pattern
      // and updates reactively when the profile changes while widget is mounted

      await tester.pumpWidget(buildTestableWidget(
        const BrainstormBox(
          title: 'Test',
          username: 'FallbackUser',
          placeholder: 'Type...',
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('FallbackUser'), findsOneWidget);

      // Update SettingsManager while BrainstormBox is still mounted
      await SettingsManager().setDisplayName('UpdatedWhileMounted');

      // Force a rebuild
      await tester.pump();

      // Username SHOULD NOW be updated because BrainstormBox listens to SettingsManager changes
      // The old value 'FallbackUser' should no longer be displayed
      expect(find.text('FallbackUser'), findsNothing);
      // And the new value should be displayed
      expect(find.text('UpdatedWhileMounted'), findsOneWidget);
    });
  });

  group('Draft persistence across navigation', () {
    testWidgets('draft survives pop → re-push to same category',
        (tester) async {
      // Mount BrainstormBox for category A, type something
      await tester.pumpWidget(buildTestableWidget(
        const BrainstormBox(
          title: 'Test',
          username: 'User',
          placeholder: 'Type...',
          category: 'cat_nav_test',
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'My important idea');
      await tester.pumpAndSettle();

      // "Navigate away" — dispose BrainstormBox
      await tester.pumpWidget(buildTestableWidget(
        const Text('Other screen'),
      ));
      await tester.pumpAndSettle();

      // "Navigate back" — re-mount BrainstormBox for same category
      await tester.pumpWidget(buildTestableWidget(
        const BrainstormBox(
          title: 'Test',
          username: 'User',
          placeholder: 'Type...',
          category: 'cat_nav_test',
        ),
      ));
      await tester.pumpAndSettle();

      // Draft should be restored
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, equals('My important idea'));
    });

    testWidgets('draft for category A is NOT loaded in category B',
        (tester) async {
      // Set up draft for category A
      await SettingsManager().setDraftIdea('category_a', 'Draft A text');

      // Mount BrainstormBox for category B
      await tester.pumpWidget(buildTestableWidget(
        const BrainstormBox(
          title: 'Test',
          username: 'User',
          placeholder: 'Type...',
          category: 'category_b',
        ),
      ));
      await tester.pumpAndSettle();

      // Category B should have empty text field
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, isEmpty);
    });
  });

  group('SettingsManager.clearAll() propagation', () {
    testWidgets('clearAll resets drafts — next BrainstormBox mount sees empty',
        (tester) async {
      // Set up draft and profile data
      await SettingsManager().setDraftIdea('my_cat', 'Saved draft');
      await SettingsManager().setDisplayName('TestUser');
      await SettingsManager().setUserLanguage('fr');

      // Clear everything
      await SettingsManager().clearAll();

      // Mount BrainstormBox — should see no draft and fallback username
      await tester.pumpWidget(buildTestableWidget(
        const BrainstormBox(
          title: 'Test',
          username: 'DefaultFallback',
          placeholder: 'Type...',
          category: 'my_cat',
        ),
      ));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, isEmpty);
      expect(find.text('DefaultFallback'), findsOneWidget);
    });
  });

  group('CategoryDetailDataFactory language reactivity', () {
    test('factories produce different titles for different locales', () async {
      final enL10n = await AppLocalizations.delegate.load(const Locale('en'));
      final csL10n = await AppLocalizations.delegate.load(const Locale('cs'));

      final enData = CategoryDetailDataFactory.centralSystems(enL10n);
      final csData = CategoryDetailDataFactory.centralSystems(csL10n);

      // Titles should be different for different languages
      expect(enData.title, isNot(equals(csData.title)),
          reason: 'EN and CS titles should differ for centralSystems');

      // Both should be non-empty
      expect(enData.title.isNotEmpty, isTrue);
      expect(csData.title.isNotEmpty, isTrue);
    });

    test('factories are stateless — calling with same l10n gives same result',
        () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      final first = CategoryDetailDataFactory.centralSystems(l10n);
      final second = CategoryDetailDataFactory.centralSystems(l10n);

      expect(first.title, equals(second.title));
      expect(first.entries.length, equals(second.entries.length));
    });
  });
}
