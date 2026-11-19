import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_preferences.dart';

class SharedPreferencesSettingsDataSource {
  static const _darkModeKey = 'settings.darkMode';
  static const _notificationsKey = 'settings.notificationsEnabled';

  Future<AppPreferences> load() async {
    final preferences = await SharedPreferences.getInstance();
    return AppPreferences(
      darkMode: preferences.getBool(_darkModeKey) ?? false,
      notificationsEnabled: preferences.getBool(_notificationsKey) ?? true,
    );
  }

  Future<void> setDarkMode(bool value) async {
    final saved = await (await SharedPreferences.getInstance()).setBool(
      _darkModeKey,
      value,
    );
    if (!saved) {
      throw const SettingsFailure('Could not save the theme setting.');
    }
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final saved = await (await SharedPreferences.getInstance()).setBool(
      _notificationsKey,
      value,
    );
    if (!saved) {
      throw const SettingsFailure('Could not save the notification setting.');
    }
  }
}

class SettingsFailure implements Exception {
  const SettingsFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
