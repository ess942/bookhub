import 'package:bookhub2/features/settings/data/datasources/shared_preferences_settings_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('persists theme and notification preferences', () async {
    SharedPreferences.setMockInitialValues({});
    final dataSource = SharedPreferencesSettingsDataSource();

    await dataSource.setDarkMode(true);
    await dataSource.setNotificationsEnabled(false);
    final preferences = await dataSource.load();

    expect(preferences.darkMode, isTrue);
    expect(preferences.notificationsEnabled, isFalse);
  });
}
