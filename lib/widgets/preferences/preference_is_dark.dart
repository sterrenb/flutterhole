import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference.dart';

/// A [Preference] for storing the theme.
class PreferenceIsDark extends PreferenceBool {
  bool defaultValue = false;

  static void applyTheme(BuildContext context, bool isDark) {
    DynamicTheme.of(context)
        .setBrightness(isDark ? Brightness.dark : Brightness.light);
  }

  PreferenceIsDark()
      : super(
      id: 'isDark',
      title: 'Dark Theme',
      description: '',
      iconData: Icons.lightbulb_outline,
      onSet: ({BuildContext context, bool didSet, dynamic value}) =>
          applyTheme(context, value as bool));
}
