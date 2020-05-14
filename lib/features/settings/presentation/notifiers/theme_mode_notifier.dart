import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/settings/services/preference_service.dart';

class ThemeModeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = getIt<PreferenceService>().get(KPrefs.activeThemeMode);

  ThemeMode get themeMode => _themeMode;

  void update() {
    _themeMode = getIt<PreferenceService>().get(KPrefs.activeThemeMode);
    print('returning $_themeMode');
    notifyListeners();
  }
}
