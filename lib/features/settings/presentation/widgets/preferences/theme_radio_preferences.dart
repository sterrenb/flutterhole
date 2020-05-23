import 'package:flutter/material.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/core/convert.dart';
import 'package:flutterhole/features/settings/presentation/notifiers/theme_mode_notifier.dart';
import 'package:flutterhole/features/settings/services/preference_service.dart';
import 'package:preferences/radio_preference.dart';
import 'package:provider/provider.dart';

class ThemeRadioPreferences extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModeNotifier>(builder: (
      BuildContext context,
      ThemeModeNotifier notifier,
      _,
    ) {
      return Column(
        children: <Widget>[
          RadioPreference(
            '${ThemeModeEnumMap[ThemeMode.system].capitalize} theme',
            '${ThemeModeEnumMap[ThemeMode.system]}',
            KPrefs.themeMode,
//            isDefault: true,
            onSelect: () => notifier.update(),
            leading: Icon(KIcons.themeSystem),
          ),
          RadioPreference(
            '${ThemeModeEnumMap[ThemeMode.light].capitalize} theme',
            '${ThemeModeEnumMap[ThemeMode.light]}',
            KPrefs.themeMode,
            onSelect: () => notifier.update(),
            leading: Icon(KIcons.themeLight),
          ),
          RadioPreference(
            '${ThemeModeEnumMap[ThemeMode.dark].capitalize} theme',
            '${ThemeModeEnumMap[ThemeMode.dark]}',
            KPrefs.themeMode,
            onSelect: () => notifier.update(),
            leading: Icon(KIcons.themeDark),
          ),
        ],
      );
    });
  }
}
