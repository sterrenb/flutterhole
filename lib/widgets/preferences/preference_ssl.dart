import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference.dart';

/// a scaffold for managing a preference that is saved between sessions, using [SharedPreferences].
class PreferenceSSL extends PreferenceBool {
  bool defaultValue = false;

  static void applyTheme(BuildContext context, bool isDark) {
    DynamicTheme.of(context)
        .setBrightness(isDark ? Brightness.dark : Brightness.light);
  }

  PreferenceSSL()
      : super(
            id: 'useSSL',
            title: 'Use SSL',
            iconData: Icons.lock,
            onSet: ({BuildContext context, bool didSet, dynamic value}) =>
                print('yay'));
}
