import 'package:shared_preferences/shared_preferences.dart';

/// Manages app-level preferences
/// Handles: language, darkMode, notifications, analytics, data collection
class AppPreferencesManager {
  static const String _onboardingShownKey = 'onboarding_shown';
  static const String _advisorTourShownKey = 'advisor_tour_shown';
  static const String _userLanguageKey = 'user_language';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _darkModeKey = 'dark_mode';
  static const String _dataCollectionKey = 'data_collection_enabled';
  static const String _analyticsKey = 'analytics_enabled';
  static const String _emailNotificationsKey = 'email_notifications';
  static const String _pushNotificationsKey = 'push_notifications';

  final SharedPreferences _prefs;

  AppPreferencesManager(this._prefs);

  // Onboarding
  bool get hasShownOnboarding => _prefs.getBool(_onboardingShownKey) ?? false;

  Future<void> setOnboardingShown(bool shown) async {
    await _prefs.setBool(_onboardingShownKey, shown);
  }

  // Advisor Tour
  bool get hasShownAdvisorTour => _prefs.getBool(_advisorTourShownKey) ?? false;

  Future<void> setAdvisorTourShown(bool shown) async {
    await _prefs.setBool(_advisorTourShownKey, shown);
  }

  // Language
  String get userLanguage => _prefs.getString(_userLanguageKey) ?? 'en';

  Future<void> setUserLanguage(String language) async {
    await _prefs.setString(_userLanguageKey, language);
  }

  // Notifications (general)
  bool get notificationsEnabled =>
      _prefs.getBool(_notificationsEnabledKey) ?? true;

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_notificationsEnabledKey, enabled);
  }

  // Dark Mode
  bool get darkModeEnabled => _prefs.getBool(_darkModeKey) ?? true;

  Future<void> setDarkModeEnabled(bool enabled) async {
    await _prefs.setBool(_darkModeKey, enabled);
  }

  // Analytics
  bool get analyticsEnabled => _prefs.getBool(_analyticsKey) ?? true;

  Future<void> setAnalyticsEnabled(bool enabled) async {
    await _prefs.setBool(_analyticsKey, enabled);
  }

  // Data Collection
  bool get dataCollectionEnabled => _prefs.getBool(_dataCollectionKey) ?? false;

  Future<void> setDataCollectionEnabled(bool enabled) async {
    await _prefs.setBool(_dataCollectionKey, enabled);
  }

  // Email Notifications
  bool get emailNotificationsEnabled =>
      _prefs.getBool(_emailNotificationsKey) ?? true;

  Future<void> setEmailNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_emailNotificationsKey, enabled);
  }

  // Push Notifications
  bool get pushNotificationsEnabled =>
      _prefs.getBool(_pushNotificationsKey) ?? true;

  Future<void> setPushNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_pushNotificationsKey, enabled);
  }

  /// Reset app preferences to defaults (for account deletion)
  Future<void> resetToDefaults() async {
    // Remove user language so default 'en' is returned
    await _prefs.remove(_userLanguageKey);
    await _prefs.remove(_darkModeKey);
    await _prefs.remove(_dataCollectionKey);
    await _prefs.remove(_analyticsKey);
    await _prefs.remove(_emailNotificationsKey);
    await _prefs.remove(_pushNotificationsKey);
  }
}
