import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:sterrenburg.github.flutterhole/widgets/app_state.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference.dart';

/// A [Preference] for storing the use of SSL (https).
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
      onSet: ({BuildContext context, bool didSet, dynamic value}) {
        AppState.of(context).updateStatus();
        AppState.of(context).updateAuthorized();
      });
}
