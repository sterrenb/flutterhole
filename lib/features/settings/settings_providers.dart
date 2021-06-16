import 'package:flutter/material.dart';
import 'package:flutterhole_web/features/entities/api_entities.dart';
import 'package:flutterhole_web/features/entities/settings_entities.dart';
import 'package:flutterhole_web/features/models/settings_models.dart';
import 'package:flutterhole_web/features/settings/settings_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>(
        (ref) => SettingsNotifier(ref.read(settingsRepositoryProvider)));

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this._repository) : super(_initial(_repository));

  final SettingsRepository _repository;

  // TODO this is pretty janky
  static SettingsState _initial(SettingsRepository _repository) {
    final userPreferences = _repository.getUserPreferences();
    return SettingsState(
      allPis: _repository.allPis(),
      activeId: _repository.activePiId(),
      userPreferences: userPreferences,
      developerPreferences: _repository.getDeveloperPreferences(),
      dev: userPreferences.devMode,
    );
  }

  Future<void> reset() async {
    await _repository.clearAll();
    state = _initial(_repository);
  }

  Future<void> resetPiHoles() async {
    await _repository.clearPiHoles();
    state = state.copyWith(
      allPis: _repository.allPis(),
      activeId: _repository.activePiId(),
    );
  }

  Future<void> resetDashboard() => savePi(
      state.active.copyWith(dashboardSettings: DashboardSettings.initial()));

  Future<void> savePi(Pi pi) async {
    await _repository.savePi(pi);
    // TODO skip activating
    await _repository.setActivePiId(pi.id);
    state = state.copyWith(
      allPis: _repository.allPis(),
      activeId: pi.id,
    );
  }

  Future<void> activate(int id) async {
    await _repository.setActivePiId(id);
    state = state.copyWith(activeId: id);
  }

  Future<void> updateDashboardEntries(List<DashboardEntry> entries) async {
    savePi(state.active.copyWith(
        dashboardSettings:
            state.active.dashboardSettings.copyWith(entries: entries)));
  }

  Future<void> saveUserPreferences(UserPreferences preferences) async {
    await _repository.saveUserPreferences(preferences);
    state = state.copyWith(userPreferences: preferences);
  }

  Future<void> saveDeveloperPreferences(
      DeveloperPreferences preferences) async {
    await _repository.saveDeveloperPreferences(preferences);
    state = state.copyWith(developerPreferences: preferences);
  }

  Future<void> saveThemeMode(ThemeMode themeMode) =>
      saveUserPreferences(state.userPreferences.copyWith(themeMode: themeMode));

  Future<void> saveUpdateFrequency(Duration frequency) => saveUserPreferences(
      state.userPreferences.copyWith(updateFrequency: frequency));

  Future<void> saveTemperatureReading(TemperatureReading reading) =>
      saveUserPreferences(
          state.userPreferences.copyWith(temperatureReading: reading));

  Future<void> toggleDevMode() => saveUserPreferences(
      state.userPreferences.copyWith(devMode: !state.userPreferences.devMode));

  Future<void> toggleUseThemeToggle() => saveDeveloperPreferences(state
      .developerPreferences
      .copyWith(useThemeToggle: !state.developerPreferences.useThemeToggle));

  Future<void> toggleAggressiveFetching() =>
      saveDeveloperPreferences(state.developerPreferences.copyWith(
          useAggressiveFetching:
              !state.developerPreferences.useAggressiveFetching));

  Future<void> saveLogLevel(LogLevel level) => saveDeveloperPreferences(
      state.developerPreferences.copyWith(logLevel: level));
}

final temperatureReadingProvider = Provider<TemperatureReading>((ref) {
  return ref.watch(settingsNotifierProvider).userPreferences.temperatureReading;
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsNotifierProvider).userPreferences.themeMode;
});

final devModeProvider = Provider<bool>((ref) {
  return ref.watch(settingsNotifierProvider).userPreferences.devMode;
});

final piColorThemeProvider =
    Provider.family<PiColorTheme, Brightness>((ref, platformBrightness) {
  final themeMode = ref.watch(themeModeProvider);
  switch (themeMode) {
    case ThemeMode.system:
      return platformBrightness == Brightness.light
          ? PiColorTheme.light()
          : PiColorTheme.dark();
    case ThemeMode.light:
      return PiColorTheme.light();
    case ThemeMode.dark:
      return PiColorTheme.dark();
  }
});

final updateFrequencyProvider = Provider<Duration>((ref) {
  return ref.watch(settingsNotifierProvider).userPreferences.updateFrequency;
});

final developerPreferencesProvider = Provider<DeveloperPreferences>((ref) {
  final settings = ref.watch(settingsNotifierProvider);

  // Return the defaults when devMode is off
  if (settings.userPreferences.devMode == false) {
    print('returning default DeveloperPreferences');
    return DeveloperPreferencesModel().entity;
  }
  return settings.developerPreferences;
});

final useAggressiveFetchingProvider = Provider<bool>((ref) {
  final devMode = ref.watch(devModeProvider);
  if (devMode == false) return false;
  return ref.watch(developerPreferencesProvider).useAggressiveFetching;
});
