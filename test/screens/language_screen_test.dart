import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/screens/user_settings/language_screen.dart';
import 'package:nanoplastics_app/services/settings_manager.dart';
import '../helpers/test_app.dart';
import '../helpers/settings_test_helper.dart';

void main() {
  setUp(() async {
    await setupServiceLocator();
  });

  group('LanguageScreen rendering', () {
    testWidgets('displays all 5 language options', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const LanguageScreen(),
      ));
      await tester.pumpAndSettle();

      // "English" appears twice (name + nativeName are same), use findsWidgets
      expect(find.text('English'), findsWidgets);
      expect(find.text('Czech'), findsOneWidget);
      expect(find.text('Spanish'), findsOneWidget);
      expect(find.text('French'), findsOneWidget);
      expect(find.text('Russian'), findsOneWidget);
    });

    testWidgets('displays native names', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const LanguageScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Čeština'), findsOneWidget);
      expect(find.text('Español'), findsOneWidget);
      expect(find.text('Français'), findsOneWidget);
      expect(find.text('Русский'), findsOneWidget);
    });

    testWidgets('displays flag emojis', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const LanguageScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('🇺🇸'), findsOneWidget);
      expect(find.text('🇨🇿'), findsOneWidget);
      expect(find.text('🇪🇸'), findsOneWidget);
      expect(find.text('🇫🇷'), findsOneWidget);
      expect(find.text('🇷🇺'), findsOneWidget);
    });

    testWidgets('English is selected by default with checkmark', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const LanguageScreen(),
      ));
      await tester.pumpAndSettle();

      // The selected language shows Icons.check inside a circle container
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });

  group('LanguageScreen interaction', () {
    testWidgets('tapping same language does nothing', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const LanguageScreen(),
      ));
      await tester.pumpAndSettle();

      // Tap English (already selected) — use first match since "English" appears twice
      await tester.tap(find.text('English').first);
      await tester.pumpAndSettle();

      // Should still have exactly one checkmark
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(SettingsManager().userLanguage, equals('en'));
    });

    testWidgets('persists language to SettingsManager', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        LanguageScreen(
          onLanguageChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      // Tap Czech
      await tester.tap(find.text('Czech'));
      await tester.pumpAndSettle();

      expect(SettingsManager().userLanguage, equals('cs'));
    });
  });
}
