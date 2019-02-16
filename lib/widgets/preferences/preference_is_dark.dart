import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference.dart';

/// a scaffold for managing a preference that is saved between sessions, using [SharedPreferences].
class PreferenceIsDark extends PreferenceBool {
  bool defaultValue = false;

  static void applyTheme(BuildContext context, bool isDark) {
    DynamicTheme.of(context)
        .setBrightness(isDark ? Brightness.dark : Brightness.light);
  }

  PreferenceIsDark()
      : super(
      id: 'isDark',
      title: 'Dark Theme (experimental)',
      description: 'Use the global dark theme',
      // TODO remove this remnant from bool prefs, OR incorporate it in the UI
      help: Container(),
      iconData: Icons.lightbulb_outline,
      onSet: ({BuildContext context, bool didSet, dynamic value}) {
        applyTheme(context, value as bool);
//        DynamicTheme.of(context).setBrightness(
//            value as bool ? Brightness.dark : Brightness.light);
      });
}
