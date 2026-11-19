import '../entities/app_preferences.dart';

abstract interface class SettingsRepository {
  Future<AppPreferences> load();

  Future<void> setDarkMode(bool value);

  Future<void> setNotificationsEnabled(bool value);
}
