import 'package:flutter/material.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/features/settings/settings_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>(
        (ref) => SettingsNotifier(ref.read(settingsRepositoryProvider)));

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this._repository)
      : super(SettingsState(
          allPis: _repository.allPis(),
          activeId: _repository.activePiId(),
          preferences: _repository.getPreferences(),
          dev: true,
        ));

  final SettingsRepository _repository;

  Future<void> reset() async {
    await _repository.clear();
    state = SettingsState(
      allPis: _repository.allPis(),
      activeId: _repository.activePiId(),
      preferences: _repository.getPreferences(),
      dev: true,
    );
  }

  Future<void> savePi(Pi pi) async {
    print('saving ${pi.title} ${pi.id}');
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

  Future<void> resetDashboard() => savePi(
      state.active.copyWith(dashboardSettings: DashboardSettings.initial()));

  Future<void> updateDashboardEntries(List<DashboardEntry> entries) async {
    savePi(state.active.copyWith(
        dashboardSettings:
            state.active.dashboardSettings.copyWith(entries: entries)));
  }

  Future<void> savePreferences(UserPreferences preferences) async {
    await _repository.savePreferences(preferences);
    state = state.copyWith(preferences: preferences);
  }

  Future<void> saveThemeMode(ThemeMode themeMode) =>
      savePreferences(state.preferences.copyWith(themeMode: themeMode));

  Future<void> saveUpdateFrequency(Duration frequency) =>
      savePreferences(state.preferences.copyWith(updateFrequency: frequency));
}

final temperatureReadingProvider = Provider<TemperatureReading>((ref) {
  return ref.watch(settingsNotifierProvider).preferences.temperatureReading;
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsNotifierProvider).preferences.themeMode;
});

// extension HookWidgetX on HookWidget {
//   Brightness platformBrightness(BuildContext context) =>
//       MediaQuery.of(context).platformBrightness;
// }

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
  return ref.watch(settingsNotifierProvider).preferences.updateFrequency;
});
