import 'dart:convert';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
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

final activePiProvider = Provider<Pi>((ref) {
  return Pi();
});

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

  Future<void> save() => storage.saveJson(storageKey, state.toJson());

  void reload() {
    final x = storage.loadJson(storageKey);
    if (x.isNotEmpty) {
      state = UserPreferences.fromJson(x);
    }
  }

  void clear() {
    storage.remove(storageKey);
    state = initialState;
  }

  void toggleDevMode() {
    state = state.copyWith(devMode: !state.devMode);
    save();
  }

  void toggleShowThemeToggle() {
    state = state.copyWith(showThemeToggle: !state.showThemeToggle);
    save();
  }

  void setThemeMode(ThemeMode value) {
    state = state.copyWith(themeMode: value);
    save();
  }

  void setTemperatureReading(TemperatureReading value) {
    state = state.copyWith(temperatureReading: value);
    save();
  }

  void setUpdateFrequency(int value) {
    state = state.copyWith(updateFrequency: value);
    save();
  }

  void setFlexScheme(FlexScheme value) {
    state = state.copyWith(flexScheme: value);
    save();
  }

  void setLogLevel(LogLevel value) {
    state = state.copyWith(logLevel: value);
    save();
  }
}

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
  print("active scheme: " + FlexColor.schemes[flexScheme]!.name);
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
    subThemesData: FlexSubThemesData(),
  );
});
