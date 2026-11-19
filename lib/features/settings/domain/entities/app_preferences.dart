class AppPreferences {
  const AppPreferences({
    this.darkMode = false,
    this.notificationsEnabled = true,
  });

  final bool darkMode;
  final bool notificationsEnabled;

  AppPreferences copyWith({bool? darkMode, bool? notificationsEnabled}) {
    return AppPreferences(
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
