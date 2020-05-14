import 'package:flutter/material.dart';
import 'package:flutterhole/core/models/exceptions.dart';
import 'package:injectable/injectable.dart';
import 'package:preferences/preferences.dart';

enum PrefType {
  string,
  bool,
  int,
  double,
  stringList,
  themeMode,
}

class KPrefs {
  KPrefs._();

  static const String useNumbersApi = 'useNumbersApi';
  static const String activeThemeMode = 'themeMode';

  static const Map<String, PrefType> prefs = {
    useNumbersApi: PrefType.bool,
    activeThemeMode: PrefType.themeMode,
  };
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

@prod
@preResolve
@singleton
class PreferenceService {
  @factoryMethod
  static Future<PreferenceService> create() async {
    await PrefService.init();
    return PreferenceService();
  }

  dynamic get(String key) {
    final type = KPrefs.prefs[key];

    if (type == null) throw PiException.notFound();

    switch (type) {
      case PrefType.string:
        return PrefService.getString(key);
      case PrefType.bool:
        return PrefService.getBool(key);

      case PrefType.int:
        return PrefService.getInt(key);

      case PrefType.double:
        return PrefService.getDouble(key);

      case PrefType.stringList:
        return PrefService.getStringList(key);
      case PrefType.themeMode:
        final String value = PrefService.getString(key) ?? 'system';
//        print('returning ${ThemeModeMapEnum[value]} for $key, $value');

        return ThemeModeMapEnum[value];
    }
  }
}
