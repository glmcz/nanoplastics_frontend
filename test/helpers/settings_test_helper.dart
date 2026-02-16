import 'package:shared_preferences/shared_preferences.dart';
import 'package:nanoplastics_app/services/settings_manager.dart';
import 'package:nanoplastics_app/services/service_locator.dart';

/// Sets up SettingsManager with mock SharedPreferences for testing.
///
/// Call this in setUp() before each test that needs SettingsManager.
/// Optionally pass initial values for specific preference keys.
Future<void> setupSettingsManager([
  Map<String, Object> values = const {},
]) async {
  SharedPreferences.setMockInitialValues(values);
  SettingsManager.resetForTesting();
  await SettingsManager.init();
}

/// Sets up both SettingsManager and ServiceLocator for widget tests.
///
/// This skips Firebase initialization (LoggerService won't call Firebase).
Future<void> setupServiceLocator([
  Map<String, Object> values = const {},
]) async {
  await setupSettingsManager(values);
  await ServiceLocator().initializeForTesting();
}
