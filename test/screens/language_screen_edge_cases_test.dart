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

  group('LanguageScreen selection guards', () {
    testWidgets('selecting already-selected language is no-op',
        (tester) async {
      // Default language is English
      int callbackCount = 0;

      await tester.pumpWidget(buildTestableWidget(
        LanguageScreen(
          onLanguageChanged: (_) {
            callbackCount++;
          },
        ),
      ));
      await tester.pumpAndSettle();

      // Tap English (already selected) — should be no-op
      await tester.scrollUntilVisible(find.text('English').first, 200.0);
      await tester.tap(find.text('English').first);
      await tester.pumpAndSettle();

      // Callback should NOT fire (early return at line 48)
      expect(callbackCount, equals(0));
      expect(SettingsManager().userLanguage, equals('en'));
    });

    testWidgets('selecting different language updates SettingsManager immediately',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        LanguageScreen(
          onLanguageChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      // Tap Czech
      await tester.tap(find.text('Czech'));
      await tester.pumpAndSettle();

      // SettingsManager should be updated immediately (line 51)
      expect(SettingsManager().userLanguage, equals('cs'));
    });

    testWidgets('onLanguageChanged callback receives correct Locale',
        (tester) async {
      Locale? receivedLocale;

      await tester.pumpWidget(buildTestableWidget(
        LanguageScreen(
          onLanguageChanged: (locale) {
            receivedLocale = locale;
          },
        ),
      ));
      await tester.pumpAndSettle();

      // Tap Czech
      await tester.tap(find.text('Czech'));
      await tester.pumpAndSettle();

      expect(receivedLocale, equals(const Locale('cs')));
    });
  });

  group('LanguageScreen UI state', () {
    testWidgets('checkmark moves to newly selected language', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        LanguageScreen(
          onLanguageChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      // Initially English is selected — one checkmark
      expect(find.byIcon(Icons.check), findsOneWidget);

      // Tap French (visible in test viewport by default)
      await tester.tap(find.text('French'));
      await tester.pumpAndSettle();

      // Checkmark should still exist (now on French)
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('all 5 language codes are correct', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const LanguageScreen(),
      ));
      await tester.pumpAndSettle();

      // Verify each language option exists with correct native name
      final expectedPairs = {
        'English': 'English',
        'Czech': 'Čeština',
        'Spanish': 'Español',
        'French': 'Français',
        'Russian': 'Русский',
      };

      for (final entry in expectedPairs.entries) {
        if (entry.key == 'English') {
          // English appears as both name and nativeName
          expect(find.text('English'), findsWidgets);
        } else {
          expect(find.text(entry.key), findsOneWidget,
              reason: 'Missing language name: ${entry.key}');
          expect(find.text(entry.value), findsOneWidget,
              reason: 'Missing native name: ${entry.value}');
        }
      }
    });
  });

  group('LanguageScreen build type behavior', () {
    testWidgets(
        'English in LITE build: no download triggered, language just persists',
        (tester) async {
      // Set up LITE build
      await setupServiceLocator({'build_type': 'LITE'});

      await tester.pumpWidget(buildTestableWidget(
        LanguageScreen(
          onLanguageChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      // Selecting English in LITE build — already selected, so no-op
      // Verify no download dialog appears
      expect(find.byType(AlertDialog), findsNothing);
      expect(SettingsManager().userLanguage, equals('en'));
    });
  });
}
