import 'dart:convert';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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

// final activePiProvider = Provider<Pi>((ref) {
//   return const Pi(
//     title: 'Demo',
//     baseUrl: 'http://example.com',
//     apiToken: String.fromEnvironment("PIHOLE_API_TOKEN", defaultValue: ""),
//   );
// });

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

  Future<void> _save() {
    return storage.saveJson(storageKey, state.toJson());
  }

  void reload() {
    final json = storage.loadJson(storageKey);
    if (json.isNotEmpty) {
      state = UserPreferences.fromJson(json);
    }
  }

  void clearPreferences() {
    state = UserPreferences(piholes: state.piholes);
    _save();
  }

  void selectPihole(Pi pi) {
    final index = state.piholes.indexOf(pi);
    state = state.copyWith(activeIndex: index);
    _save();
  }

  void deletePiholes() {
    state = state.copyWith(piholes: defaultPiholes);
    _save();
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

    final active = state.piholes.elementAt(state.activeIndex);
    final list = List<Pi>.from(state.piholes, growable: true);
    final item = list.removeAt(from);
    list.insert(to, item);
    final activeIndex = list.indexOf(active);
    state = state.copyWith(piholes: list, activeIndex: activeIndex);
    _save();
  }

  void savePihole({Pi? oldValue, required Pi newValue}) {
    if (oldValue != null && state.piholes.contains(oldValue)) {
      final list = List<Pi>.from(state.piholes);
      list[state.piholes.indexOf(oldValue)] = newValue;
      savePiholes(list);
    } else {
      savePiholes([...state.piholes, newValue]);
    }
  }

  void deletePihole(Pi value) {
    if (state.piholes.length > 1) {
      final list = List<Pi>.from(state.piholes)
        ..removeWhere((element) => element == value);
      savePiholes(list);
    }
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

final allPiholesProvider = Provider<List<Pi>>((ref) {
  return ref.watch(UserPreferencesNotifier.provider).piholes;
});

final piProvider = Provider<Pi>((ref) {
  final prefs = ref.watch(UserPreferencesNotifier.provider);
  return prefs.piholes
      .elementAt(prefs.activeIndex.clamp(0, prefs.piholes.length - 1));
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(UserPreferencesNotifier.provider).themeMode;
});

final devModeProvider = Provider<bool>((ref) {
  return ref.watch(UserPreferencesNotifier.provider).devMode;
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
    useSubThemes: true,
  );
});

final darkThemeProvider = Provider<ThemeData>((ref) {
  final flexScheme = ref.watch(flexSchemeProvider);
  return FlexThemeData.dark(
    scheme: flexScheme,
    useSubThemes: true,
    subThemesData: const FlexSubThemesData(),
  );
});
