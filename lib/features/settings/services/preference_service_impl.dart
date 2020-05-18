import 'package:flutter/material.dart';
import 'package:flutterhole/core/models/exceptions.dart';
import 'package:flutterhole/features/settings/services/preference_service.dart';
import 'package:injectable/injectable.dart';
import 'package:preferences/preferences.dart';

@prod
@preResolve
@singleton
@RegisterAs(PreferenceService)
class PrServiceImpl implements PreferenceService {
  @factoryMethod
  static Future<PrServiceImpl> create() async {
    await PrefService.init();
    return PrServiceImpl();
  }

  dynamic _get<T>(String key) {
    if (T == null) throw PiException.notFound();

    switch (T) {
      case String:
        return PrefService.getString(key);
      case bool:
        return PrefService.getBool(key);

      case int:
        return PrefService.getInt(key);

      case double:
        return PrefService.getDouble(key);

      case List:
        return PrefService.getStringList(key);
      default:
        throw TypeError();
    }
  }

  void _set(String key, dynamic value) {
    switch (value.runtimeType) {
      case String:
        return PrefService.setString(key, value);
      case bool:
        return PrefService.setBool(key, value);

      case int:
        return PrefService.setInt(key, value);

      case double:
        return PrefService.setDouble(key, value);

      case List:
        return PrefService.setStringList(key, value);
      default:
        throw TypeError();
    }
  }

  @override
  bool checkFirstUse() {
    final bool result = _get<bool>(KPrefs.isFirstUse);

    if (result == null) {
      _set(KPrefs.isFirstUse, false);
    }

    return result ?? true;
  }

  @override
  Future<void> reset() async {
    PrefService.clear();
  }

  @override
  bool get useNumbersApi => _get<bool>(KPrefs.useNumbersApi) ?? true;

  @override
  ThemeMode get themeMode {
    final String value = _get<String>(KPrefs.themeMode) ?? 'system';
    return ThemeModeMapEnum[value];
  }

  @override
  int get queryLogMaxResults => _get<int>(KPrefs.queryLogMaxResults) ?? 100;

  @override
  Future<void> setQueryLogMaxResults(int maxResults) async =>
      _set(KPrefs.queryLogMaxResults, maxResults);
}
