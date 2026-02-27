import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'managers/user_profile_manager.dart';
import 'managers/app_preferences_manager.dart';
import 'managers/pdf_cache_manager.dart';
import 'managers/update_state_manager.dart';

/// Centralized settings coordinator
/// Delegates to specialized managers for different concerns
class SettingsManager {
  static final SettingsManager _instance = SettingsManager._internal();
  static bool _isInitialized = false;

  late SharedPreferences _prefs;
  late UserProfileManager _profileManager;
  late AppPreferencesManager _preferencesManager;
  late PdfCacheManager _pdfCacheManager;
  late UpdateStateManager _updateStateManager;

  SettingsManager._internal();

  factory SettingsManager() {
    return _instance;
  }

  void _checkInitialized() {
    if (!_isInitialized) {
      throw Exception(
        'SettingsManager must be initialized first. Call SettingsManager.init() before using.',
      );
    }
  }

  /// Initialize the settings manager
  static Future<void> init() async {
    if (!_isInitialized) {
      _instance._prefs = await SharedPreferences.getInstance();
      _instance._migrateLegacyBase64Fields();

      // Initialize delegated managers
      _instance._profileManager = UserProfileManager(_instance._prefs);
      _instance._preferencesManager = AppPreferencesManager(_instance._prefs);
      _instance._pdfCacheManager = PdfCacheManager();
      _instance._updateStateManager = UpdateStateManager(_instance._prefs);

      _isInitialized = true;
    }
  }

  /// One-time migration: decode legacy base64-stored fields to plain text
  void _migrateLegacyBase64Fields() {
    if (_prefs.getBool('legacy_base64_migrated') ?? false) return;
    for (final key in ['user_id', 'user_name', 'user_specialty']) {
      final raw = _prefs.getString(key);
      if (raw == null) continue;
      try {
        final decoded = utf8.decode(base64Decode(raw));
        _prefs.setString(key, decoded);
      } catch (_) {
        // Already plain text
      }
    }
    _prefs.setBool('legacy_base64_migrated', true);
  }

  // ===== Profile Manager Delegation =====
  void addDisplayNameListener(Function(String) callback) {
    _checkInitialized();
    _profileManager.addDisplayNameListener(callback);
  }

  void removeDisplayNameListener(Function(String) callback) {
    _checkInitialized();
    _profileManager.removeDisplayNameListener(callback);
  }

  String? get userId {
    _checkInitialized();
    return _profileManager.userId;
  }

  Future<void> setUserId(String id) async {
    _checkInitialized();
    await _profileManager.setUserId(id);
  }

  bool get isProfileRegistered {
    _checkInitialized();
    return _profileManager.isProfileRegistered;
  }

  Future<void> setProfileRegistered(bool registered) async {
    _checkInitialized();
    await _profileManager.setProfileRegistered(registered);
  }

  String? get userName {
    _checkInitialized();
    return _profileManager.userName;
  }

  Future<void> setUserName(String name) async {
    _checkInitialized();
    await _profileManager.setUserName(name);
  }

  String? get userSpecialty {
    _checkInitialized();
    return _profileManager.userSpecialty;
  }

  Future<void> setUserSpecialty(String specialty) async {
    _checkInitialized();
    await _profileManager.setUserSpecialty(specialty);
  }

  String get displayName {
    _checkInitialized();
    return _profileManager.displayName;
  }

  Future<void> setDisplayName(String name) async {
    _checkInitialized();
    await _profileManager.setDisplayName(name);
  }

  String get email {
    _checkInitialized();
    return _profileManager.email;
  }

  Future<void> setEmail(String email) async {
    _checkInitialized();
    await _profileManager.setEmail(email);
  }

  String get bio {
    _checkInitialized();
    return _profileManager.bio;
  }

  Future<void> setBio(String bio) async {
    _checkInitialized();
    await _profileManager.setBio(bio);
  }

  String? get avatarPath {
    _checkInitialized();
    return _profileManager.avatarPath;
  }

  Future<void> setAvatarPath(String? path) async {
    _checkInitialized();
    await _profileManager.setAvatarPath(path);
  }

  // ===== Preferences Manager Delegation =====
  bool get hasShownOnboarding {
    _checkInitialized();
    return _preferencesManager.hasShownOnboarding;
  }

  Future<void> setOnboardingShown(bool shown) async {
    _checkInitialized();
    await _preferencesManager.setOnboardingShown(shown);
  }

  bool get hasShownAdvisorTour {
    _checkInitialized();
    return _preferencesManager.hasShownAdvisorTour;
  }

  Future<void> setAdvisorTourShown(bool shown) async {
    _checkInitialized();
    await _preferencesManager.setAdvisorTourShown(shown);
  }

  String get userLanguage {
    _checkInitialized();
    return _preferencesManager.userLanguage;
  }

  Future<void> setUserLanguage(String language) async {
    _checkInitialized();
    await _preferencesManager.setUserLanguage(language);
  }

  bool get notificationsEnabled {
    _checkInitialized();
    return _preferencesManager.notificationsEnabled;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _checkInitialized();
    await _preferencesManager.setNotificationsEnabled(enabled);
  }

  bool get darkModeEnabled {
    _checkInitialized();
    return _preferencesManager.darkModeEnabled;
  }

  Future<void> setDarkModeEnabled(bool enabled) async {
    _checkInitialized();
    await _preferencesManager.setDarkModeEnabled(enabled);
  }

  bool get analyticsEnabled {
    _checkInitialized();
    return _preferencesManager.analyticsEnabled;
  }

  Future<void> setAnalyticsEnabled(bool enabled) async {
    _checkInitialized();
    await _preferencesManager.setAnalyticsEnabled(enabled);
  }

  bool get dataCollectionEnabled {
    _checkInitialized();
    return _preferencesManager.dataCollectionEnabled;
  }

  Future<void> setDataCollectionEnabled(bool enabled) async {
    _checkInitialized();
    await _preferencesManager.setDataCollectionEnabled(enabled);
  }

  bool get emailNotificationsEnabled {
    _checkInitialized();
    return _preferencesManager.emailNotificationsEnabled;
  }

  Future<void> setEmailNotificationsEnabled(bool enabled) async {
    _checkInitialized();
    await _preferencesManager.setEmailNotificationsEnabled(enabled);
  }

  bool get pushNotificationsEnabled {
    _checkInitialized();
    return _preferencesManager.pushNotificationsEnabled;
  }

  Future<void> setPushNotificationsEnabled(bool enabled) async {
    _checkInitialized();
    await _preferencesManager.setPushNotificationsEnabled(enabled);
  }

  // ===== PDF Cache Manager Delegation =====
  Future<File?> getPdfForLanguage(String language) async {
    _checkInitialized();
    return await _pdfCacheManager.getPdfForLanguage(language);
  }

  Future<List<String>> getCachedPdfLanguages() async {
    _checkInitialized();
    return await _pdfCacheManager.getCachedPdfLanguages();
  }

  Future<void> savePdfLocally(String language, List<int> bytes) async {
    _checkInitialized();
    await _pdfCacheManager.savePdfLocally(language, bytes);
  }

  Future<void> deleteCachedPdf(String language) async {
    _checkInitialized();
    await _pdfCacheManager.deleteCachedPdf(language);
  }

  // ===== Update State Manager Delegation =====
  bool get updateAvailable {
    _checkInitialized();
    return _updateStateManager.updateAvailable;
  }

  Future<void> setUpdateAvailable(bool available) async {
    _checkInitialized();
    await _updateStateManager.setUpdateAvailable(available);
  }

  String? get latestVersion {
    _checkInitialized();
    return _updateStateManager.latestVersion;
  }

  Future<void> setLatestVersion(String version) async {
    _checkInitialized();
    await _updateStateManager.setLatestVersion(version);
  }

  String? get updateDownloadUrl {
    _checkInitialized();
    return _updateStateManager.updateDownloadUrl;
  }

  Future<void> setUpdateDownloadUrl(String url) async {
    _checkInitialized();
    await _updateStateManager.setUpdateDownloadUrl(url);
  }

  DateTime? get lastVersionCheck {
    _checkInitialized();
    return _updateStateManager.lastVersionCheck;
  }

  Future<void> setLastVersionCheck(DateTime time) async {
    _checkInitialized();
    await _updateStateManager.setLastVersionCheck(time);
  }

  String? get lastReleaseTagId {
    _checkInitialized();
    return _updateStateManager.lastReleaseTagId;
  }

  Future<void> setLastReleaseTagId(String id) async {
    _checkInitialized();
    await _updateStateManager.setLastReleaseTagId(id);
  }

  DateTime? get lastUpdateCheckTime {
    _checkInitialized();
    return _updateStateManager.lastUpdateCheckTime;
  }

  Future<void> setLastUpdateCheckTime(DateTime time) async {
    _checkInitialized();
    await _updateStateManager.setLastUpdateCheckTime(time);
  }

  String? get currentAppVersion {
    _checkInitialized();
    return _updateStateManager.currentAppVersion;
  }

  Future<void> setCurrentAppVersion(String version) async {
    _checkInitialized();
    await _updateStateManager.setCurrentAppVersion(version);
  }

  String? get lastDownloadedApkPath {
    _checkInitialized();
    return _updateStateManager.lastDownloadedApkPath;
  }

  Future<void> setLastDownloadedApkPath(String? path) async {
    _checkInitialized();
    await _updateStateManager.setLastDownloadedApkPath(path);
  }

  int? get lastDownloadedApkSize {
    _checkInitialized();
    return _updateStateManager.lastDownloadedApkSize;
  }

  Future<void> setLastDownloadedApkSize(int size) async {
    _checkInitialized();
    await _updateStateManager.setLastDownloadedApkSize(size);
  }

  String get buildType {
    _checkInitialized();
    return _updateStateManager.buildType;
  }

  Future<void> setBuildType(String type) async {
    _checkInitialized();
    await _updateStateManager.setBuildType(type);
  }

  // ===== Draft Ideas (kept in SettingsManager) =====
  String? getDraftIdea(String categoryKey) {
    _checkInitialized();
    return _prefs.getString('draft_idea_$categoryKey');
  }

  Future<void> setDraftIdea(String categoryKey, String text) async {
    _checkInitialized();
    if (text.isEmpty) {
      await _prefs.remove('draft_idea_$categoryKey');
    } else {
      await _prefs.setString('draft_idea_$categoryKey', text);
    }
  }

  Future<void> clearDraftIdea(String categoryKey) async {
    _checkInitialized();
    await _prefs.remove('draft_idea_$categoryKey');
  }

  // ===== Lifecycle Management =====
  /// Clear all settings (for testing or reset)
  Future<void> clearAll() async {
    _checkInitialized();
    await _prefs.clear();
  }

  /// Reset to defaults for account deletion
  Future<void> resetToDefaults() async {
    _checkInitialized();
    await _profileManager.clearProfile();
    await _preferencesManager.resetToDefaults();
    await _updateStateManager.clearUpdateState();
  }

  /// Delete account data (clears profile but preserves preferences)
  Future<void> deleteAccount() async {
    _checkInitialized();
    await _profileManager.clearProfile();
    await _updateStateManager.clearUpdateState();
  }

  @visibleForTesting
  static void resetForTesting() {
    _isInitialized = false;
  }
}
