import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nanoplastics_app/services/settings_manager.dart';
import 'package:nanoplastics_app/services/service_locator.dart';

void main() {
  group('SettingsManager initialization guard', () {
    test('accessing userLanguage before init() throws', () {
      SharedPreferences.setMockInitialValues({});
      SettingsManager.resetForTesting();

      expect(
        () => SettingsManager().userLanguage,
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('must be initialized first'),
        )),
      );
    });

    test('accessing hasShownOnboarding before init() throws', () {
      SharedPreferences.setMockInitialValues({});
      SettingsManager.resetForTesting();

      expect(
        () => SettingsManager().hasShownOnboarding,
        throwsA(isA<Exception>()),
      );
    });

    test('setting a value before init() throws', () {
      SharedPreferences.setMockInitialValues({});
      SettingsManager.resetForTesting();

      expect(
        () => SettingsManager().setUserLanguage('cs'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('SettingsManager init() idempotency', () {
    test('calling init() twice does not crash', () async {
      SharedPreferences.setMockInitialValues({});
      SettingsManager.resetForTesting();

      await SettingsManager.init();
      await SettingsManager.init(); // Second call should be idempotent

      // Should still work normally
      expect(SettingsManager().userLanguage, equals('en'));
    });

    test('init() with pre-populated prefs loads existing values', () async {
      SharedPreferences.setMockInitialValues({
        'user_language': 'fr',
        'onboarding_shown': true,
        'display_name': 'ExistingUser',
        'dark_mode': false,
      });
      SettingsManager.resetForTesting();
      await SettingsManager.init();

      final s = SettingsManager();
      expect(s.userLanguage, equals('fr'));
      expect(s.hasShownOnboarding, isTrue);
      expect(s.displayName, equals('ExistingUser'));
      expect(s.darkModeEnabled, isFalse);
    });

    test('second init() does not overwrite values set after first init',
        () async {
      SharedPreferences.setMockInitialValues({});
      SettingsManager.resetForTesting();

      await SettingsManager.init();
      await SettingsManager().setUserLanguage('es');

      // Second init should be no-op because _isInitialized is true
      await SettingsManager.init();

      expect(SettingsManager().userLanguage, equals('es'));
    });
  });

  group('ServiceLocator initialization', () {
    test(
        'initializeForTesting() after SettingsManager.init() provides settingsManager',
        () async {
      SharedPreferences.setMockInitialValues({});
      SettingsManager.resetForTesting();
      await SettingsManager.init();
      await ServiceLocator().initializeForTesting();

      final sm = ServiceLocator().settingsManager;
      expect(sm.userLanguage, equals('en'));
    });

    test('initializeForTesting() provides loggerService without Firebase crash',
        () async {
      SharedPreferences.setMockInitialValues({});
      SettingsManager.resetForTesting();
      await SettingsManager.init();
      await ServiceLocator().initializeForTesting();

      // LoggerService should be accessible without throwing
      final logger = ServiceLocator().loggerService;
      expect(logger, isNotNull);
    });
  });
}
