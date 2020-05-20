import 'package:flutter/material.dart';

/// Constant preference keys for map-like storage implementations.
class KPrefs {
  KPrefs._();

  static const String isFirstUse = 'isFirstUse';
  static const String useNumbersApi = 'useNumbersApi';
  static const String themeMode = 'themeMode';
  static const String queryLogMaxResults = 'queryLogMaxResults';
  static const String footerMessage = 'footerMessage';
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

  Future<void> reset();

  bool get useNumbersApi;

  ThemeMode get themeMode;

  int get queryLogMaxResults;

  Future<void> setQueryLogMaxResults(int maxResults);

  String get footerMessage;
}
