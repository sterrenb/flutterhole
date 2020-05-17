import 'package:flutter/material.dart' show ThemeMode;

class KPrefs {
  KPrefs._();

  static const String isFirstUse = 'isFirstUse';
  static const String useNumbersApi = 'useNumbersApi';
  static const String themeMode = 'themeMode';
}

const ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

const ThemeModeMapEnum = {
  'system': ThemeMode.system,
  'light': ThemeMode.light,
  'dark': ThemeMode.dark,
};

abstract class PreferenceService {
  bool checkFirstUse();

  bool get useNumbersApi;

  ThemeMode get themeMode;
}
