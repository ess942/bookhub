import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/shared_preferences_settings_data_source.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/app_preferences.dart';
import '../../domain/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(SharedPreferencesSettingsDataSource()),
);

final appPreferencesProvider =
    AsyncNotifierProvider<AppPreferencesController, AppPreferences>(
      AppPreferencesController.new,
    );

class AppPreferencesController extends AsyncNotifier<AppPreferences> {
  late SettingsRepository _repository;

  @override
  Future<AppPreferences> build() {
    _repository = ref.watch(settingsRepositoryProvider);
    return _repository.load();
  }

  Future<void> setDarkMode(bool value) async {
    await _update(
      (preferences) => preferences.copyWith(darkMode: value),
      () => _repository.setDarkMode(value),
    );
  }

  Future<void> setNotificationsEnabled(bool value) async {
    await _update(
      (preferences) => preferences.copyWith(notificationsEnabled: value),
      () => _repository.setNotificationsEnabled(value),
    );
  }

  Future<void> _update(
    AppPreferences Function(AppPreferences) update,
    Future<void> Function() persist,
  ) async {
    final current = state.value;
    if (current == null) {
      throw const SettingsFailure('Settings are still loading. Try again.');
    }
    state = AsyncData(update(current));
    try {
      await persist();
    } catch (_) {
      state = AsyncData(current);
      rethrow;
    }
  }
}
