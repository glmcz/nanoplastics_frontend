import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nanoplastics_app/screens/onboarding_screen.dart';
import 'package:nanoplastics_app/screens/main_screen.dart';
import 'package:nanoplastics_app/services/settings_manager.dart';
import 'package:nanoplastics_app/config/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nanoplastics_app/l10n/app_localizations.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    SettingsManager.resetForTesting();
    await SettingsManager.init();
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
      home: const OnboardingScreen(),
    );
  }

  testWidgets('full onboarding flow: slides → Get Started → MainScreen',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    // Verify we're on the OnboardingScreen
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(PageView), findsOneWidget);

    // Slide 1: Tap Next
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Slide 2: Back button should appear, tap Next again
    expect(find.byType(TextButton), findsOneWidget);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Slide 3 (last): Button should show "Get Started" text
    // Tap it to complete onboarding
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify onboarding is marked as shown
    expect(SettingsManager().hasShownOnboarding, isTrue);

    // Verify we navigated to MainScreen
    expect(find.byType(MainScreen), findsOneWidget);
  });

  testWidgets('close icon skips onboarding and goes to MainScreen',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    // Tap close icon
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(SettingsManager().hasShownOnboarding, isTrue);
    expect(find.byType(MainScreen), findsOneWidget);
  });
}
