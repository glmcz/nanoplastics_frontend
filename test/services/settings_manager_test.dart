import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/services/settings_manager.dart';
import '../helpers/settings_test_helper.dart';

void main() {
  group('SettingsManager initialization', () {
    test('initializes successfully with empty prefs', () async {
      await setupSettingsManager();
      final settings = SettingsManager();
      // Should not throw
      expect(settings.userLanguage, equals('en'));
    });
  });

  group('SettingsManager - onboarding', () {
    setUp(() async => await setupSettingsManager());

    test('hasShownOnboarding defaults to false', () {
      expect(SettingsManager().hasShownOnboarding, isFalse);
    });

    test('setOnboardingShown(true) persists and reads back', () async {
      await SettingsManager().setOnboardingShown(true);
      expect(SettingsManager().hasShownOnboarding, isTrue);
    });
  });

  group('SettingsManager - language', () {
    setUp(() async => await setupSettingsManager());

    test('userLanguage defaults to "en"', () {
      expect(SettingsManager().userLanguage, equals('en'));
    });

    test('setUserLanguage("cs") persists and reads back', () async {
      await SettingsManager().setUserLanguage('cs');
      expect(SettingsManager().userLanguage, equals('cs'));
    });

    test('setUserLanguage("es") persists and reads back', () async {
      await SettingsManager().setUserLanguage('es');
      expect(SettingsManager().userLanguage, equals('es'));
    });
  });

  group('SettingsManager - notifications', () {
    setUp(() async => await setupSettingsManager());

    test('notificationsEnabled defaults to true', () {
      expect(SettingsManager().notificationsEnabled, isTrue);
    });

    test('setNotificationsEnabled(false) persists', () async {
      await SettingsManager().setNotificationsEnabled(false);
      expect(SettingsManager().notificationsEnabled, isFalse);
    });
  });

  group('SettingsManager - userId (encrypted)', () {
    setUp(() async => await setupSettingsManager());

    test('userId is null when not set', () {
      expect(SettingsManager().userId, isNull);
    });

    test('setUserId stores base64 encoded and getUserId decodes it', () async {
      await SettingsManager().setUserId('test-uuid-123');
      expect(SettingsManager().userId, equals('test-uuid-123'));
    });
  });

  group('SettingsManager - profile', () {
    setUp(() async => await setupSettingsManager());

    test('isProfileRegistered defaults to false', () {
      expect(SettingsManager().isProfileRegistered, isFalse);
    });

    test('displayName defaults to empty string', () {
      expect(SettingsManager().displayName, equals(''));
    });

    test('email defaults to empty string', () {
      expect(SettingsManager().email, equals(''));
    });

    test('bio defaults to empty string', () {
      expect(SettingsManager().bio, equals(''));
    });

    test('setProfileRegistered/setDisplayName/setEmail/setBio persist', () async {
      final s = SettingsManager();
      await s.setProfileRegistered(true);
      await s.setDisplayName('Jane Doe');
      await s.setEmail('jane@example.com');
      await s.setBio('Marine Biologist');

      expect(s.isProfileRegistered, isTrue);
      expect(s.displayName, equals('Jane Doe'));
      expect(s.email, equals('jane@example.com'));
      expect(s.bio, equals('Marine Biologist'));
    });
  });

  group('SettingsManager - userName (encrypted)', () {
    setUp(() async => await setupSettingsManager());

    test('userName is null when not set', () {
      expect(SettingsManager().userName, isNull);
    });

    test('setUserName encodes and getUserName decodes', () async {
      await SettingsManager().setUserName('TestUser');
      expect(SettingsManager().userName, equals('TestUser'));
    });
  });

  group('SettingsManager - drafts', () {
    setUp(() async => await setupSettingsManager());

    test('getDraftIdea returns null when no draft saved', () {
      expect(SettingsManager().getDraftIdea('some_category'), isNull);
    });

    test('setDraftIdea persists text for category key', () async {
      await SettingsManager().setDraftIdea('cat1', 'My great idea');
      expect(SettingsManager().getDraftIdea('cat1'), equals('My great idea'));
    });

    test('setDraftIdea with empty string removes the draft', () async {
      await SettingsManager().setDraftIdea('cat1', 'Draft text');
      await SettingsManager().setDraftIdea('cat1', '');
      expect(SettingsManager().getDraftIdea('cat1'), isNull);
    });

    test('clearDraftIdea removes the draft', () async {
      await SettingsManager().setDraftIdea('cat1', 'Draft');
      await SettingsManager().clearDraftIdea('cat1');
      expect(SettingsManager().getDraftIdea('cat1'), isNull);
    });

    test('drafts are independent per category', () async {
      await SettingsManager().setDraftIdea('cat1', 'Idea for cat1');
      await SettingsManager().setDraftIdea('cat2', 'Idea for cat2');
      expect(SettingsManager().getDraftIdea('cat1'), equals('Idea for cat1'));
      expect(SettingsManager().getDraftIdea('cat2'), equals('Idea for cat2'));
    });
  });

  group('SettingsManager - dark mode', () {
    setUp(() async => await setupSettingsManager());

    test('darkModeEnabled defaults to true', () {
      expect(SettingsManager().darkModeEnabled, isTrue);
    });

    test('setDarkModeEnabled(false) persists', () async {
      await SettingsManager().setDarkModeEnabled(false);
      expect(SettingsManager().darkModeEnabled, isFalse);
    });
  });

  group('SettingsManager - analytics and data collection', () {
    setUp(() async => await setupSettingsManager());

    test('analyticsEnabled defaults to true', () {
      expect(SettingsManager().analyticsEnabled, isTrue);
    });

    test('dataCollectionEnabled defaults to false', () {
      expect(SettingsManager().dataCollectionEnabled, isFalse);
    });

    test('setAnalyticsEnabled(false) persists', () async {
      await SettingsManager().setAnalyticsEnabled(false);
      expect(SettingsManager().analyticsEnabled, isFalse);
    });

    test('setDataCollectionEnabled(true) persists', () async {
      await SettingsManager().setDataCollectionEnabled(true);
      expect(SettingsManager().dataCollectionEnabled, isTrue);
    });
  });

  group('SettingsManager - email/push notifications', () {
    setUp(() async => await setupSettingsManager());

    test('emailNotificationsEnabled defaults to true', () {
      expect(SettingsManager().emailNotificationsEnabled, isTrue);
    });

    test('pushNotificationsEnabled defaults to true', () {
      expect(SettingsManager().pushNotificationsEnabled, isTrue);
    });

    test('setEmailNotificationsEnabled(false) persists', () async {
      await SettingsManager().setEmailNotificationsEnabled(false);
      expect(SettingsManager().emailNotificationsEnabled, isFalse);
    });

    test('setPushNotificationsEnabled(false) persists', () async {
      await SettingsManager().setPushNotificationsEnabled(false);
      expect(SettingsManager().pushNotificationsEnabled, isFalse);
    });
  });

  group('SettingsManager - update settings', () {
    setUp(() async => await setupSettingsManager());

    test('updateAvailable defaults to false', () {
      expect(SettingsManager().updateAvailable, isFalse);
    });

    test('latestVersion is null when not set', () {
      expect(SettingsManager().latestVersion, isNull);
    });

    test('setUpdateAvailable(true) persists', () async {
      await SettingsManager().setUpdateAvailable(true);
      expect(SettingsManager().updateAvailable, isTrue);
    });

    test('setLatestVersion persists', () async {
      await SettingsManager().setLatestVersion('2.0.0');
      expect(SettingsManager().latestVersion, equals('2.0.0'));
    });

    test('lastVersionCheck round-trips DateTime correctly', () async {
      final now = DateTime(2025, 6, 15, 12, 30, 0);
      await SettingsManager().setLastVersionCheck(now);
      expect(SettingsManager().lastVersionCheck, equals(now));
    });

    test('lastUpdateCheckTime round-trips DateTime correctly', () async {
      final now = DateTime(2025, 6, 15, 14, 0, 0);
      await SettingsManager().setLastUpdateCheckTime(now);
      expect(SettingsManager().lastUpdateCheckTime, equals(now));
    });
  });

  group('SettingsManager - buildType', () {
    setUp(() async => await setupSettingsManager());

    test('buildType defaults to "UNKNOWN"', () {
      expect(SettingsManager().buildType, equals('UNKNOWN'));
    });

    test('setBuildType("FULL") persists', () async {
      await SettingsManager().setBuildType('FULL');
      expect(SettingsManager().buildType, equals('FULL'));
    });

    test('setBuildType("LITE") persists', () async {
      await SettingsManager().setBuildType('LITE');
      expect(SettingsManager().buildType, equals('LITE'));
    });
  });

  group('SettingsManager - avatar', () {
    setUp(() async => await setupSettingsManager());

    test('avatarPath is null when not set', () {
      expect(SettingsManager().avatarPath, isNull);
    });

    test('setAvatarPath stores and retrieves path', () async {
      await SettingsManager().setAvatarPath('/path/to/avatar.jpg');
      expect(SettingsManager().avatarPath, equals('/path/to/avatar.jpg'));
    });

    test('setAvatarPath(null) removes the path', () async {
      await SettingsManager().setAvatarPath('/path/to/avatar.jpg');
      await SettingsManager().setAvatarPath(null);
      expect(SettingsManager().avatarPath, isNull);
    });
  });

  group('SettingsManager - clearAll', () {
    setUp(() async => await setupSettingsManager());

    test('clearAll resets all values to defaults', () async {
      final s = SettingsManager();
      await s.setUserLanguage('cs');
      await s.setOnboardingShown(true);
      await s.setDisplayName('Test');
      await s.setDarkModeEnabled(false);

      await s.clearAll();

      expect(s.userLanguage, equals('en'));
      expect(s.hasShownOnboarding, isFalse);
      expect(s.displayName, equals(''));
      expect(s.darkModeEnabled, isTrue);
    });
  });

  group('SettingsManager - initial values from prefs', () {
    test('loads pre-existing values from SharedPreferences', () async {
      await setupSettingsManager({
        'user_language': 'fr',
        'onboarding_shown': true,
        'display_name': 'PreLoaded',
      });

      final s = SettingsManager();
      expect(s.userLanguage, equals('fr'));
      expect(s.hasShownOnboarding, isTrue);
      expect(s.displayName, equals('PreLoaded'));
    });
  });
}
