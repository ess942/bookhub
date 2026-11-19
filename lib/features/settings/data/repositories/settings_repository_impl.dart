import '../../domain/entities/app_preferences.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/shared_preferences_settings_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._dataSource);

  final SharedPreferencesSettingsDataSource _dataSource;

  @override
  Future<AppPreferences> load() => _dataSource.load();

  @override
  Future<void> setDarkMode(bool value) => _dataSource.setDarkMode(value);

  @override
  Future<void> setNotificationsEnabled(bool value) =>
      _dataSource.setNotificationsEnabled(value);
}
