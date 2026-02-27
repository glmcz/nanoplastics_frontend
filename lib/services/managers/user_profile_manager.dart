import 'package:shared_preferences/shared_preferences.dart';

/// Manages user profile data
/// Handles: userId, userName, userSpecialty, displayName, email, bio, avatar, isProfileRegistered
class UserProfileManager {
  static const String _userIdKey = 'user_id';
  static const String _profileRegisteredKey = 'profile_registered';
  static const String _userNameKey = 'user_name';
  static const String _userSpecialtyKey = 'user_specialty';
  static const String _displayNameKey = 'display_name';
  static const String _emailKey = 'email';
  static const String _bioKey = 'bio';
  static const String _avatarPathKey = 'avatar_path';

  final SharedPreferences _prefs;

  // Listeners for reactive updates
  final List<Function(String)> _displayNameListeners = [];

  UserProfileManager(this._prefs);

  /// Subscribe to display name changes
  void addDisplayNameListener(Function(String) callback) {
    _displayNameListeners.add(callback);
  }

  /// Unsubscribe from display name changes
  void removeDisplayNameListener(Function(String) callback) {
    _displayNameListeners.remove(callback);
  }

  /// Notify all listeners of display name change
  void _notifyDisplayNameListeners(String newName) {
    for (final callback in _displayNameListeners) {
      callback(newName);
    }
  }

  // User ID
  String? get userId => _prefs.getString(_userIdKey);

  Future<void> setUserId(String id) async {
    await _prefs.setString(_userIdKey, id);
  }

  // Is Profile Registered
  bool get isProfileRegistered =>
      _prefs.getBool(_profileRegisteredKey) ?? false;

  Future<void> setProfileRegistered(bool registered) async {
    await _prefs.setBool(_profileRegisteredKey, registered);
  }

  // User Name
  String? get userName => _prefs.getString(_userNameKey);

  Future<void> setUserName(String name) async {
    await _prefs.setString(_userNameKey, name);
  }

  // User Specialty
  String? get userSpecialty => _prefs.getString(_userSpecialtyKey);

  Future<void> setUserSpecialty(String specialty) async {
    await _prefs.setString(_userSpecialtyKey, specialty);
  }

  // Display Name
  String get displayName => _prefs.getString(_displayNameKey) ?? '';

  Future<void> setDisplayName(String name) async {
    await _prefs.setString(_displayNameKey, name);
    _notifyDisplayNameListeners(name);
  }

  // Email
  String get email => _prefs.getString(_emailKey) ?? '';

  Future<void> setEmail(String email) async {
    await _prefs.setString(_emailKey, email);
  }

  // Bio
  String get bio => _prefs.getString(_bioKey) ?? '';

  Future<void> setBio(String bio) async {
    await _prefs.setString(_bioKey, bio);
  }

  // Avatar Path
  String? get avatarPath => _prefs.getString(_avatarPathKey);

  Future<void> setAvatarPath(String? path) async {
    if (path == null) {
      await _prefs.remove(_avatarPathKey);
    } else {
      await _prefs.setString(_avatarPathKey, path);
    }
  }

  /// Clear all profile data (for account deletion)
  Future<void> clearProfile() async {
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_profileRegisteredKey);
    await _prefs.remove(_userNameKey);
    await _prefs.remove(_userSpecialtyKey);
    await _prefs.remove(_displayNameKey);
    await _prefs.remove(_emailKey);
    await _prefs.remove(_bioKey);
    await _prefs.remove(_avatarPathKey);
  }
}
