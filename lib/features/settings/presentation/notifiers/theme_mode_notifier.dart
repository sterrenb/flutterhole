import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/settings/services/preference_service.dart';

// TODO maybe notify directly from the service, e.g. via stream
class ThemeModeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = getIt<PreferenceService>().themeMode;

  ThemeMode get themeMode => _themeMode;

  void update() {
    _themeMode = getIt<PreferenceService>().themeMode;
    notifyListeners();
  }
}
