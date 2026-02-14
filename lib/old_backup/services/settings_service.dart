import 'package:nanoplastics_app/models/user_settings.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;

  SettingsService._internal() {
    _settings = _getDefaultSettings();
  }

  late UserSettings _settings;

  //getter
  UserSettings get settings => _settings;

  // setter
  void updateSettings(UserSettings newSettings){
    _settings = newSettings;
    _saveToStorage();
  }

  void updateNotifications(bool enabled) {
    _settings = _settings.copyWith(notificationsEnabled: enabled);
    _saveToStorage();
  }

  static UserSettings _getDefaultSettings() {
    return UserSettings(
      fullName: 'Guest User',
      email: 'user@nanohive.app',
      avatarPath: null,
      notificationsEnabled: true,
      language: 'en',
    );
  }

  Future<void> _saveToStorage() async {
    //TODO save to storage
  }

  void resetToDefault() {
    _settings = _getDefaultSettings();
    _saveToStorage();
  }
}