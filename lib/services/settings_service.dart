import 'dart:convert';
import 'dart:developer';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final Provider<SettingsService> provider =
      Provider<SettingsService>((ref) => throw UnimplementedError());

  final SharedPreferences _preferences;

  SettingsService(this._preferences);

  Future<void> clear() async {
    await _preferences.clear();
  }

  Future<void> remove(String key) async {
    await _preferences.remove(key);
  }

  Future<void> saveJson(String key, Map<String, dynamic> json) async {
    _preferences.setString(key, jsonEncode(json));
  }

  Map<String, dynamic> loadJson(
    String key, {
    Map<String, dynamic> orElse = const {},
  }) {
    final string = _preferences.getString(key);
    if (string == null) return orElse;
    return jsonDecode(string);
  }
}

final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
    (_) async => await SharedPreferences.getInstance());

class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  static final provider =
      StateNotifierProvider<UserPreferencesNotifier, UserPreferences>((ref) {
    return UserPreferencesNotifier(ref.watch(SettingsService.provider));
  });

  static const storageKey = "preferences";
  static const initialState = UserPreferences(
      // devMode: kDebugMode,
      );

  final SettingsService storage;

  UserPreferencesNotifier(this.storage) : super(initialState) {
    reload();
  }

  Pi get _active => state.piholes.elementAt(state.activeIndex);

  Future<void> _save() {
    return storage.saveJson(storageKey, state.toJson());
  }

  void reload() {
    final json = storage.loadJson(storageKey);
    if (json.isNotEmpty) {
      state = UserPreferences.fromJson(json);
    }
  }

  void setPreferences(UserPreferences value) {
    state = value;
    _save();
  }

  UserPreferences clearPreferences() {
    final oldValue = state;
    state = UserPreferences(
      piholes: state.piholes,
      activeIndex: state.activeIndex,
      notificationsRead: state.notificationsRead,
    );
    _save();
    return oldValue;
  }

  void selectPihole(Pi pi) {
    final index = state.piholes.indexOf(pi);
    state = state.copyWith(activeIndex: index);
    _save();
  }

  List<Pi> deletePiholes() {
    final list = state.piholes;
    state = state.copyWith(piholes: defaultPiholes);
    _save();
    return list;
  }

  void savePiholes(List<Pi> value) {
    state = state.copyWith(piholes: value);
    _save();
  }

  void reorderPiholes(int from, int to) {
    if (from == to) return;
    if (from < to) {
      to -= 1;
    }

    final list = List<Pi>.from(state.piholes, growable: true);
    final item = list.removeAt(from);
    list.insert(to, item);
    final activeIndex = list.indexOf(_active);
    state = state.copyWith(piholes: list, activeIndex: activeIndex);
    _save();
  }

  void savePihole({Pi? oldValue, required Pi newValue}) {
    log('savePihole:${newValue.title}:${newValue.toString().length} bytes');
    if (oldValue != null && state.piholes.contains(oldValue)) {
      final list = List<Pi>.from(state.piholes);
      list[state.piholes.indexOf(oldValue)] = newValue;
      savePiholes(list);
    } else {
      savePiholes([...state.piholes, newValue]);
    }
  }

  void updateDashboardEntry(DashboardEntry entry) {
    log('updateDashboardEntry:${_active.title}:$entry');

    final index = _active.dashboard.indexWhere((v) => v.id == entry.id);
    if (index < 0) {
      log(
        'updateDashboardEntry:missing entry:${entry.id}',
        level: LogLevel.warning.index,
        error: entry,
      );
      return;
    }

    final list = List<DashboardEntry>.from(_active.dashboard);
    list[index] = entry;

    savePihole(oldValue: _active, newValue: _active.copyWith(dashboard: list));
  }

  void moveDashboardEntry(int from, int to) {
    if (to < 0 || from == to || to > _active.dashboard.length - 1) return;

    log('moveDashboardEntry:${_active.title}:$from->$to');
    final list = List<DashboardEntry>.from(_active.dashboard);

    final entry = list.removeAt(from);
    list.insert(to, entry);

    savePihole(oldValue: _active, newValue: _active.copyWith(dashboard: list));
  }

  void swapDashboardEntries(DashboardEntry a, DashboardEntry b) {
    log('swapDashboardEntries:${a.id}:${b.id}');
    final dashboard = [..._active.dashboard];

    final first = dashboard.indexWhere((element) => element.id == a.id);
    final second = dashboard.indexWhere((element) => element.id == b.id);

    DashboardEntry xa = dashboard[first];
    DashboardEntry xy = dashboard[second];

    if (xa.constraints is DashboardTileConstraintsCount &&
        xy.constraints is DashboardTileConstraintsCount) {
      xa = xa.copyWith(constraints: dashboard[second].constraints);
      xy = xy.copyWith(constraints: dashboard[first].constraints);
    } else {
      xa = xa.copyWith.constraints(
          crossAxisCount: dashboard[second].constraints.crossAxisCount);
      xy = xy.copyWith.constraints(
          crossAxisCount: dashboard[first].constraints.crossAxisCount);
    }

    dashboard[first] = xy;
    dashboard[second] = xa;
    savePihole(
        oldValue: _active, newValue: _active.copyWith(dashboard: dashboard));
  }

  void addPihole(Pi value, int index) {
    log('addPihole:${value.title}:$index');
    final list = List<Pi>.from(state.piholes, growable: true);
    list.insert(index.clamp(0, state.piholes.length), value);
    state = state.copyWith(piholes: list);
    _save();
  }

  int deletePihole(Pi value) {
    final index = state.piholes.indexOf(value);
    if (state.piholes.length > 1) {
      log('deletePihole:${value.title}:$index');
      final list = List<Pi>.from(state.piholes, growable: true)
        ..removeAt(index);
      savePiholes(list);
    }
    return index;
  }

  void markNotificationsAsRead(List<String> values) {
    for (final notification in values) {
      log('markNotificationsAsRead:$notification');
    }
    state = state.copyWith(
        notificationsRead: {...state.notificationsRead, ...values}.toList());
    _save();
  }

  void enableIsDev() {
    state = state.copyWith(isDev: true);
    _save();
  }

  void toggleDevMode() {
    state = state.copyWith(devMode: !state.devMode);
    _save();
  }

  void toggleShowThemeToggle() {
    state = state.copyWith(showThemeToggle: !state.showThemeToggle);
    _save();
  }

  void setThemeMode(ThemeMode value) {
    state = state.copyWith(themeMode: value);
    _save();
  }

  void setTemperatureReading(TemperatureReading value) {
    state = state.copyWith(temperatureReading: value);
    _save();
  }

  void setUpdateFrequency(int value) {
    state = state.copyWith(updateFrequency: value);
    _save();
  }

  void setFlexScheme(FlexScheme value) {
    state = state.copyWith(flexScheme: value);
    _save();
  }

  void setLogLevel(LogLevel value) {
    state = state.copyWith(logLevel: value);
    _save();
  }
}

final activeIndexProvider = Provider<int>((ref) {
  return ref.watch(UserPreferencesNotifier.provider).activeIndex;
});

final notificationsReadProvider = Provider<List<String>>((ref) {
  return ref.watch(UserPreferencesNotifier.provider).notificationsRead;
});

final notificationsUnReadProvider = Provider<List<String>>((ref) {
  final read = ref.watch(UserPreferencesNotifier.provider).notificationsRead;
  return [...defaultNotifications]
    ..removeWhere((element) => read.contains(element));
});

final allPiholesProvider = Provider<List<Pi>>((ref) {
  return ref.watch(UserPreferencesNotifier.provider).piholes;
});

final piProvider = Provider<Pi>((ref) {
  final prefs = ref.watch(UserPreferencesNotifier.provider);
  return prefs.piholes
      .elementAt(prefs.activeIndex.clamp(0, prefs.piholes.length - 1));
});

final dashboardTileConstraintsProvider =
    Provider.family<DashboardTileConstraints, DashboardID>((ref, id) {
  final pi = ref.watch(piProvider);
  return pi.dashboard
      .firstWhere((element) => element.id == id,
          orElse: () => DashboardEntry.defaultDashboard.first)
      .constraints;
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(UserPreferencesNotifier.provider).themeMode;
});

final devModeProvider = Provider<bool>((ref) {
  return ref.watch(UserPreferencesNotifier.provider).devMode;
});

final isDevProvider = Provider<bool>((ref) {
  return ref.watch(UserPreferencesNotifier.provider).isDev;
});

final temperatureReadingProvider = Provider<TemperatureReading>((ref) {
  return ref.watch(UserPreferencesNotifier.provider).temperatureReading;
});

final showThemeToggleProvider = Provider<bool>((ref) {
  final preferences = ref.watch(UserPreferencesNotifier.provider);
  return preferences.showThemeToggle;
});

final flexSchemeProvider = Provider<FlexScheme>((ref) {
  return ref.watch(UserPreferencesNotifier.provider).flexScheme;
});

final logLevelProvider = Provider<LogLevel>((ref) {
  return ref.watch(UserPreferencesNotifier.provider).logLevel;
});

final updateFrequencyProvider = Provider<int>((ref) {
  return ref.watch(UserPreferencesNotifier.provider).updateFrequency;
});

final flexSchemeDataProvider = Provider<FlexSchemeData>((ref) {
  final flexScheme = ref.watch(flexSchemeProvider);
  return FlexColor.schemes[flexScheme]!;
});

final lightThemeProvider = Provider<ThemeData>((ref) {
  final flexScheme = ref.watch(flexSchemeProvider);
  return FlexThemeData.light(
    scheme: flexScheme,
  );
});

final darkThemeProvider = Provider<ThemeData>((ref) {
  final flexScheme = ref.watch(flexSchemeProvider);
  return FlexThemeData.dark(
    scheme: flexScheme,
    subThemesData: const FlexSubThemesData(),
  );
});

final packageInfoProvider =
    FutureProvider<PackageInfo>((_) => PackageInfo.fromPlatform());
