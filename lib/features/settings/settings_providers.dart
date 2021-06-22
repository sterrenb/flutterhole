import 'package:flutter/material.dart';
import 'package:flutterhole_web/features/entities/logging_entities.dart';
import 'package:flutterhole_web/features/entities/settings_entities.dart';
import 'package:flutterhole_web/features/settings/settings_repository.dart';
import 'package:flutterhole_web/package_providers.dart';
import 'package:flutterhole_web/top_level_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pihole_api/pihole_api.dart';

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>(
        (ref) => SettingsNotifier(ref.read(settingsRepositoryProvider)));

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this._repository)
      : super(SettingsState(
          allPis: _repository.allPis(),
          activeId: _repository.activePiId(),
          userPreferences: _repository.getUserPreferences(),
        ));

  final SettingsRepository _repository;

  Future<void> reset() async {
    await _repository.clearAll();
    state = SettingsState(
      allPis: _repository.allPis(),
      activeId: _repository.activePiId(),
      userPreferences: _repository.getUserPreferences(),
    );
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

  Future<void> saveThemeMode(ThemeMode themeMode) =>
      saveUserPreferences(state.userPreferences.copyWith(themeMode: themeMode));

  Future<void> saveUpdateFrequency(Duration frequency) => saveUserPreferences(
      state.userPreferences.copyWith(updateFrequency: frequency));

  Future<void> saveTemperatureReading(TemperatureReading reading) =>
      saveUserPreferences(
          state.userPreferences.copyWith(temperatureReading: reading));

  Future<void> toggleDevMode() => saveUserPreferences(
      state.userPreferences.copyWith(devMode: !state.userPreferences.devMode));

  Future<void> toggleUseThemeToggle() =>
      saveUserPreferences(state.userPreferences
          .copyWith(useThemeToggle: !state.userPreferences.useThemeToggle));

  Future<void> toggleAggressiveFetching() =>
      saveUserPreferences(state.userPreferences.copyWith(
          useAggressiveFetching: !state.userPreferences.useAggressiveFetching));

  Future<void> saveLogLevel(LogLevel level) =>
      saveUserPreferences(state.userPreferences.copyWith(logLevel: level));
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

final useAggressiveFetchingProvider = Provider<bool>((ref) {
  final devMode = ref.watch(devModeProvider);
  if (devMode == false) return false;
  return ref.watch(userPreferencesProvider).useAggressiveFetching;
});

final activePiProvider = Provider<Pi>((ref) {
  final settings = ref.watch(settingsNotifierProvider);
  return settings.active;
});

final activePiParamsProvider = Provider<PiholeRepositoryParams>((ref) {
  final pi = ref.watch(activePiProvider);
  final dio = ref.watch(newDioProvider(pi));

  return PiholeRepositoryParams(
    dio: dio,
    baseUrl: pi.baseUrl,
    useSsl: pi.useSsl,
    apiPath: pi.apiPath,
    apiPort: pi.apiPort,
    apiTokenRequired: pi.apiTokenRequired,
    apiToken: pi.apiToken,
    allowSelfSignedCertificates: pi.allowSelfSignedCertificates,
    adminHome: pi.adminHome,
  );
});
