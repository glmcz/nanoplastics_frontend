import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nanoplastics_app/screens/main_screen.dart';
import 'package:nanoplastics_app/screens/category_detail_new_screen.dart';
import 'package:nanoplastics_app/widgets/brainstorm_box.dart';
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
      home: const MainScreen(),
    );
  }

  testWidgets('navigate to category detail and interact with brainstorm box',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    // Verify we're on MainScreen
    expect(find.byType(MainScreen), findsOneWidget);

    // Tap first category card (Central Systems — psychology icon)
    await tester.tap(find.byIcon(Icons.psychology_outlined));
    await tester.pumpAndSettle();

    // Verify we navigated to CategoryDetailNewScreen
    expect(find.byType(CategoryDetailNewScreen), findsOneWidget);

    // Scroll down to find the BrainstormBox
    await tester.dragUntilVisible(
      find.byType(BrainstormBox),
      find.byType(SingleChildScrollView).first,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BrainstormBox), findsOneWidget);

    // Try submitting with short text — should show validation error
    final textField = find.descendant(
      of: find.byType(BrainstormBox),
      matching: find.byType(TextField),
    );
    await tester.enterText(textField, 'Short');
    await tester.pumpAndSettle();

    final submitButton = find.descendant(
      of: find.byType(BrainstormBox),
      matching: find.byType(ElevatedButton),
    );
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    // Validation snackbar should appear
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
