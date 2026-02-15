import 'package:shared_preferences/shared_preferences.dart';
import 'encryption_service.dart';

class SettingsManager {
  static const String _onboardingShownKey = 'onboarding_shown';
  static const String _userLanguageKey = 'user_language';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _userIdKey = 'user_id';
  static const String _profileRegisteredKey = 'profile_registered';
  static const String _userNameKey = 'user_name';
  static const String _userSpecialtyKey = 'user_specialty';

  // Profile settings keys
  static const String _displayNameKey = 'display_name';
  static const String _emailKey = 'email';
  static const String _bioKey = 'bio';
  static const String _avatarPathKey = 'avatar_path';
  static const String _darkModeKey = 'dark_mode';
  static const String _dataCollectionKey = 'data_collection_enabled';
  static const String _analyticsKey = 'analytics_enabled';
  static const String _emailNotificationsKey = 'email_notifications';
  static const String _pushNotificationsKey = 'push_notifications';

  // Update-related keys
  static const String _updateAvailableKey = 'update_available';
  static const String _latestVersionKey = 'latest_version';
  static const String _updateDownloadUrlKey = 'update_download_url';
  static const String _lastVersionCheckKey = 'last_version_check';

  // Build type identifier
  static const String _buildTypeKey = 'build_type';

  static final SettingsManager _instance = SettingsManager._internal();
  static bool _isInitialized = false;

  late SharedPreferences _prefs;

  SettingsManager._internal();

  factory SettingsManager() {
    return _instance;
  }

  /// Initialize the settings manager
  static Future<void> init() async {
    if (!_isInitialized) {
      _instance._prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }

  /// Check if onboarding has been shown
  bool get hasShownOnboarding {
    _checkInitialized();
    final value = _prefs.getBool(_onboardingShownKey) ?? false;
    return value;
  }

  /// Set onboarding as shown
  Future<void> setOnboardingShown(bool shown) async {
    _checkInitialized();
    await _prefs.setBool(_onboardingShownKey, shown);
  }

  /// Get user language preference
  String get userLanguage {
    _checkInitialized();
    return _prefs.getString(_userLanguageKey) ?? 'en';
  }

  /// Set user language preference
  Future<void> setUserLanguage(String language) async {
    _checkInitialized();
    await _prefs.setString(_userLanguageKey, language);
  }

  /// Check if notifications are enabled
  bool get notificationsEnabled {
    _checkInitialized();
    return _prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  /// Set notifications enabled/disabled
  Future<void> setNotificationsEnabled(bool enabled) async {
    _checkInitialized();
    await _prefs.setBool(_notificationsEnabledKey, enabled);
  }

  /// Get user ID (encrypted)
  String? get userId {
    _checkInitialized();
    final encrypted = _prefs.getString(_userIdKey);
    if (encrypted == null) return null;
    return EncryptionService.decryptString(encrypted);
  }

  /// Set user ID (encrypted)
  Future<void> setUserId(String id) async {
    _checkInitialized();
    final encrypted = EncryptionService.encryptString(id);
    await _prefs.setString(_userIdKey, encrypted);
  }

  /// Check if user profile is registered
  bool get isProfileRegistered {
    _checkInitialized();
    return _prefs.getBool(_profileRegisteredKey) ?? false;
  }

  /// Set profile registration status
  Future<void> setProfileRegistered(bool registered) async {
    _checkInitialized();
    await _prefs.setBool(_profileRegisteredKey, registered);
  }

  /// Get user name (encrypted)
  String? get userName {
    _checkInitialized();
    final encrypted = _prefs.getString(_userNameKey);
    if (encrypted == null) return null;
    return EncryptionService.decryptString(encrypted);
  }

  /// Set user name (encrypted)
  Future<void> setUserName(String name) async {
    _checkInitialized();
    final encrypted = EncryptionService.encryptString(name);
    await _prefs.setString(_userNameKey, encrypted);
  }

  /// Get user specialty (encrypted)
  String? get userSpecialty {
    _checkInitialized();
    final encrypted = _prefs.getString(_userSpecialtyKey);
    if (encrypted == null) return null;
    return EncryptionService.decryptString(encrypted);
  }

  /// Set user specialty (encrypted)
  Future<void> setUserSpecialty(String specialty) async {
    _checkInitialized();
    final encrypted = EncryptionService.encryptString(specialty);
    await _prefs.setString(_userSpecialtyKey, encrypted);
  }

  /// Clear all settings
  Future<void> clearAll() async {
    _checkInitialized();
    await _prefs.clear();
  }

  /// Check if manager is initialized
  void _checkInitialized() {
    if (!_isInitialized) {
      throw Exception(
          'SettingsManager must be initialized first. Call SettingsManager.init() in main()');
    }
  }

  /// Reset to defaults
  Future<void> resetToDefaults() async {
    _checkInitialized();
    await clearAll();
  }

  /// Get build type (FULL or LITE)
  String get buildType {
    _checkInitialized();
    return _prefs.getString(_buildTypeKey) ?? 'UNKNOWN';
  }

  /// Set build type identifier
  Future<void> setBuildType(String type) async {
    _checkInitialized();
    await _prefs.setString(_buildTypeKey, type);
  }

  // Draft idea persistence (per category)

  String? getDraftIdea(String category) {
    _checkInitialized();
    return _prefs.getString('draft_idea_$category');
  }

  Future<void> setDraftIdea(String category, String text) async {
    _checkInitialized();
    if (text.isEmpty) {
      await _prefs.remove('draft_idea_$category');
    } else {
      await _prefs.setString('draft_idea_$category', text);
    }
  }

  Future<void> clearDraftIdea(String category) async {
    _checkInitialized();
    await _prefs.remove('draft_idea_$category');
  }

  // Profile settings getters and setters

  /// Get display name
  String get displayName {
    _checkInitialized();
    return _prefs.getString(_displayNameKey) ?? '';
  }

  /// Set display name
  Future<void> setDisplayName(String name) async {
    _checkInitialized();
    await _prefs.setString(_displayNameKey, name);
  }

  /// Get email
  String get email {
    _checkInitialized();
    return _prefs.getString(_emailKey) ?? '';
  }

  /// Set email
  Future<void> setEmail(String email) async {
    _checkInitialized();
    await _prefs.setString(_emailKey, email);
  }

  /// Get bio
  String get bio {
    _checkInitialized();
    return _prefs.getString(_bioKey) ?? '';
  }

  /// Set bio
  Future<void> setBio(String bio) async {
    _checkInitialized();
    await _prefs.setString(_bioKey, bio);
  }

  /// Get avatar path
  String? get avatarPath {
    _checkInitialized();
    return _prefs.getString(_avatarPathKey);
  }

  /// Set avatar path
  Future<void> setAvatarPath(String? path) async {
    _checkInitialized();
    if (path != null) {
      await _prefs.setString(_avatarPathKey, path);
    } else {
      await _prefs.remove(_avatarPathKey);
    }
  }

  /// Check if dark mode is enabled
  bool get darkModeEnabled {
    _checkInitialized();
    return _prefs.getBool(_darkModeKey) ?? true;
  }

  /// Set dark mode
  Future<void> setDarkModeEnabled(bool enabled) async {
    _checkInitialized();
    await _prefs.setBool(_darkModeKey, enabled);
  }

  /// Check if data collection is enabled
  bool get dataCollectionEnabled {
    _checkInitialized();
    return _prefs.getBool(_dataCollectionKey) ?? false;
  }

  /// Set data collection
  Future<void> setDataCollectionEnabled(bool enabled) async {
    _checkInitialized();
    await _prefs.setBool(_dataCollectionKey, enabled);
  }

  /// Check if analytics is enabled
  bool get analyticsEnabled {
    _checkInitialized();
    return _prefs.getBool(_analyticsKey) ?? true;
  }

  /// Set analytics
  Future<void> setAnalyticsEnabled(bool enabled) async {
    _checkInitialized();
    await _prefs.setBool(_analyticsKey, enabled);
  }

  /// Check if email notifications are enabled
  bool get emailNotificationsEnabled {
    _checkInitialized();
    return _prefs.getBool(_emailNotificationsKey) ?? true;
  }

  /// Set email notifications
  Future<void> setEmailNotificationsEnabled(bool enabled) async {
    _checkInitialized();
    await _prefs.setBool(_emailNotificationsKey, enabled);
  }

  /// Check if push notifications are enabled
  bool get pushNotificationsEnabled {
    _checkInitialized();
    return _prefs.getBool(_pushNotificationsKey) ?? true;
  }

  /// Set push notifications
  Future<void> setPushNotificationsEnabled(bool enabled) async {
    _checkInitialized();
    await _prefs.setBool(_pushNotificationsKey, enabled);
  }

  // Update-related getters and setters

  /// Check if an update is available
  bool get updateAvailable {
    _checkInitialized();
    return _prefs.getBool(_updateAvailableKey) ?? false;
  }

  /// Set update available status
  Future<void> setUpdateAvailable(bool available) async {
    _checkInitialized();
    await _prefs.setBool(_updateAvailableKey, available);
  }

  /// Get latest available version
  String? get latestVersion {
    _checkInitialized();
    return _prefs.getString(_latestVersionKey);
  }

  /// Set latest available version
  Future<void> setLatestVersion(String version) async {
    _checkInitialized();
    await _prefs.setString(_latestVersionKey, version);
  }

  /// Get update download URL
  String? get updateDownloadUrl {
    _checkInitialized();
    return _prefs.getString(_updateDownloadUrlKey);
  }

  /// Set update download URL
  Future<void> setUpdateDownloadUrl(String url) async {
    _checkInitialized();
    await _prefs.setString(_updateDownloadUrlKey, url);
  }

  /// Get last version check timestamp
  DateTime? get lastVersionCheck {
    _checkInitialized();
    final timestamp = _prefs.getString(_lastVersionCheckKey);
    if (timestamp == null) return null;
    return DateTime.tryParse(timestamp);
  }

  /// Set last version check timestamp
  Future<void> setLastVersionCheck(DateTime dateTime) async {
    _checkInitialized();
    await _prefs.setString(_lastVersionCheckKey, dateTime.toIso8601String());
  }
}
