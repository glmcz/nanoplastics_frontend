import 'package:shared_preferences/shared_preferences.dart';

/// Manages update state and version tracking
/// Handles: update metadata, version tracking, APK state
class UpdateStateManager {
  static const String _updateAvailableKey = 'update_available';
  static const String _latestVersionKey = 'latest_version';
  static const String _updateDownloadUrlKey = 'update_download_url';
  static const String _lastVersionCheckKey = 'last_version_check';
  static const String _lastReleaseTagIdKey = 'last_release_tag_id';
  static const String _lastUpdateCheckTimeKey = 'last_update_check_time';
  static const String _currentAppVersionKey = 'current_app_version';
  static const String _lastDownloadedApkPathKey = 'last_downloaded_apk_path';
  static const String _lastDownloadedApkSizeKey = 'last_downloaded_apk_size';
  static const String _buildTypeKey = 'build_type';

  final SharedPreferences _prefs;

  UpdateStateManager(this._prefs);

  // Update Available
  bool get updateAvailable => _prefs.getBool(_updateAvailableKey) ?? false;

  Future<void> setUpdateAvailable(bool available) async {
    await _prefs.setBool(_updateAvailableKey, available);
  }

  // Latest Version
  String? get latestVersion => _prefs.getString(_latestVersionKey);

  Future<void> setLatestVersion(String version) async {
    await _prefs.setString(_latestVersionKey, version);
  }

  // Update Download URL
  String? get updateDownloadUrl => _prefs.getString(_updateDownloadUrlKey);

  Future<void> setUpdateDownloadUrl(String url) async {
    await _prefs.setString(_updateDownloadUrlKey, url);
  }

  // Last Version Check
  DateTime? get lastVersionCheck {
    final stored = _prefs.getString(_lastVersionCheckKey);
    return stored != null ? DateTime.parse(stored) : null;
  }

  Future<void> setLastVersionCheck(DateTime time) async {
    await _prefs.setString(_lastVersionCheckKey, time.toIso8601String());
  }

  // Last Release Tag ID
  String? get lastReleaseTagId => _prefs.getString(_lastReleaseTagIdKey);

  Future<void> setLastReleaseTagId(String id) async {
    await _prefs.setString(_lastReleaseTagIdKey, id);
  }

  // Last Update Check Time
  DateTime? get lastUpdateCheckTime {
    final stored = _prefs.getString(_lastUpdateCheckTimeKey);
    return stored != null ? DateTime.parse(stored) : null;
  }

  Future<void> setLastUpdateCheckTime(DateTime time) async {
    await _prefs.setString(_lastUpdateCheckTimeKey, time.toIso8601String());
  }

  // Current App Version
  String? get currentAppVersion => _prefs.getString(_currentAppVersionKey);

  Future<void> setCurrentAppVersion(String version) async {
    await _prefs.setString(_currentAppVersionKey, version);
  }

  // Last Downloaded APK Path
  String? get lastDownloadedApkPath =>
      _prefs.getString(_lastDownloadedApkPathKey);

  Future<void> setLastDownloadedApkPath(String? path) async {
    if (path == null) {
      await _prefs.remove(_lastDownloadedApkPathKey);
    } else {
      await _prefs.setString(_lastDownloadedApkPathKey, path);
    }
  }

  // Last Downloaded APK Size
  int? get lastDownloadedApkSize => _prefs.getInt(_lastDownloadedApkSizeKey);

  Future<void> setLastDownloadedApkSize(int size) async {
    await _prefs.setInt(_lastDownloadedApkSizeKey, size);
  }

  // Build Type
  String get buildType => _prefs.getString(_buildTypeKey) ?? 'UNKNOWN';

  Future<void> setBuildType(String type) async {
    await _prefs.setString(_buildTypeKey, type);
  }

  /// Clear update state (for cleanup)
  Future<void> clearUpdateState() async {
    await _prefs.remove(_updateAvailableKey);
    await _prefs.remove(_latestVersionKey);
    await _prefs.remove(_updateDownloadUrlKey);
    await _prefs.remove(_lastVersionCheckKey);
    await _prefs.remove(_lastReleaseTagIdKey);
    await _prefs.remove(_lastUpdateCheckTimeKey);
    await _prefs.remove(_lastDownloadedApkPathKey);
    await _prefs.remove(_lastDownloadedApkSizeKey);
  }
}
