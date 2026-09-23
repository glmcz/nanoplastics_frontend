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

  // Navigation only. Two things make the rest of this flow untestable on a
  // device: text input cannot be simulated under the live binding, so
  // enterText leaves the field empty and the submit button looks dead; and
  // CategoryDetailNewScreen runs a repeating AnimationController, so
  // pumpAndSettle never returns and the run burns ten minutes before failing.
  // Typing, validation and submission are covered in
  // test/features/idea_submission_test.dart, where enterText works.
  testWidgets('tapping a category opens its detail screen with the idea box',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(MainScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.psychology_outlined));
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(CategoryDetailNewScreen), findsOneWidget);

    // Slivers build lazily, so scroll until the finder resolves and only then
    // assert it — the natural assertion order is backwards here.
    await tester.dragUntilVisible(
      find.byType(BrainstormBox),
      find.byType(SingleChildScrollView).first,
      const Offset(0, -200),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(BrainstormBox), findsOneWidget);
  });
}
