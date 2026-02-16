import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nanoplastics_app/screens/user_settings/language_screen.dart';
import 'package:nanoplastics_app/services/settings_manager.dart';
import 'package:nanoplastics_app/services/service_locator.dart';
import 'package:nanoplastics_app/config/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nanoplastics_app/l10n/app_localizations.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'onboarding_shown': true,
    });
    SettingsManager.resetForTesting();
    await SettingsManager.init();
    await ServiceLocator().initializeForTesting();
  });

  Widget buildApp() {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('cs'),
        Locale('es'),
        Locale('fr'),
        Locale('ru'),
      ],
      theme: AppTheme.darkTheme,
      home: const LanguageScreen(),
    );
  }

  testWidgets('language screen displays all 5 languages and persists selection',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    // Verify all languages are displayed
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Czech'), findsOneWidget);
    expect(find.text('Spanish'), findsOneWidget);
    expect(find.text('French'), findsOneWidget);
    expect(find.text('Russian'), findsOneWidget);

    // English should be selected by default
    expect(SettingsManager().userLanguage, equals('en'));

    // Select Czech
    await tester.tap(find.text('Czech'));
    await tester.pumpAndSettle();

    // Verify language was persisted
    expect(SettingsManager().userLanguage, equals('cs'));
  });
}
