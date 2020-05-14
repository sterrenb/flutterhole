import 'package:flutter/material.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/core/convert.dart';
import 'package:flutterhole/features/settings/presentation/notifiers/theme_mode_notifier.dart';
import 'package:flutterhole/features/settings/presentation/widgets/pihole_theme_builder.dart';
import 'package:flutterhole/features/settings/services/preference_service.dart';
import 'package:flutterhole/widgets/layout/list_title.dart';
import 'package:preferences/preferences.dart';
import 'package:provider/provider.dart';

class UserPreferencesPage extends StatefulWidget {
  @override
  _UserPreferencesPageState createState() => _UserPreferencesPageState();
}

class _UserPreferencesPageState extends State<UserPreferencesPage> {
  void _onThemeSelect() {
    Provider.of<ThemeModeNotifier>(context, listen: false).update();
  }

  @override
  Widget build(BuildContext context) {
    return PiholeThemeBuilder(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Preferences'),
        ),
        body: ListView(
          children: <Widget>[
            ListTitle('Customization'),
            RadioPreference(
              '${ThemeModeEnumMap[ThemeMode.system].capitalize} theme',
              '${ThemeModeEnumMap[ThemeMode.system]}',
              KPrefs.activeThemeMode,
              isDefault: true,
              onSelect: _onThemeSelect,
              leading: Icon(KIcons.themeSystem),
            ),
            RadioPreference(
              '${ThemeModeEnumMap[ThemeMode.light].capitalize} theme',
              '${ThemeModeEnumMap[ThemeMode.light]}',
              KPrefs.activeThemeMode,
              onSelect: _onThemeSelect,
              leading: Icon(KIcons.themeLight),
            ),
            RadioPreference(
              '${ThemeModeEnumMap[ThemeMode.dark].capitalize} theme',
              '${ThemeModeEnumMap[ThemeMode.dark]}',
              KPrefs.activeThemeMode,
              onSelect: _onThemeSelect,
              leading: Icon(KIcons.themeDark),
            ),
            ListTitle('Data'),
            SwitchPreference(
              'Use numbers API',
              KPrefs.useNumbersApi,
              defaultVal: true,
              desc:
              'If enabled, the dashboard will fetch number trivia from the Numbers API.',
            ),
          ],
        ),
      ),
    );
  }
}

class UserPreferencesListTile extends StatefulWidget {
  const UserPreferencesListTile({
    Key key,
  }) : super(key: key);

  @override
  _UserPreferencesListTileState createState() =>
      _UserPreferencesListTileState();
}

class _UserPreferencesListTileState extends State<UserPreferencesListTile> {
  void _onThemeSelect() {
    Provider.of<ThemeModeNotifier>(context, listen: false).update();
  }

  @override
  Widget build(BuildContext context) {
    return PreferencePageLink(
      'Preferences',
      page: PreferencePage([
        PreferenceTitle('Theme'),
        RadioPreference(
          '${ThemeModeEnumMap[ThemeMode.system].capitalize} theme',
          '${ThemeModeEnumMap[ThemeMode.system]}',
          KPrefs.activeThemeMode,
          isDefault: true,
          onSelect: _onThemeSelect,
          leading: Icon(KIcons.themeSystem),
        ),
        RadioPreference(
          '${ThemeModeEnumMap[ThemeMode.light].capitalize} theme',
          '${ThemeModeEnumMap[ThemeMode.light]}',
          KPrefs.activeThemeMode,
          onSelect: _onThemeSelect,
          leading: Icon(KIcons.themeLight),
        ),
        RadioPreference(
          '${ThemeModeEnumMap[ThemeMode.dark].capitalize} theme',
          '${ThemeModeEnumMap[ThemeMode.dark]}',
          KPrefs.activeThemeMode,
          onSelect: _onThemeSelect,
          leading: Icon(KIcons.themeDark),
        ),
        PreferenceTitle('Data'),
        SwitchPreference(
          'Use numbers API',
          KPrefs.useNumbersApi,
          defaultVal: true,
          desc:
          'If enabled, the dashboard will fetch number trivia from the Numbers API.',
        ),
      ]),
      leading: Icon(KIcons.preferences),
      trailing: Icon(KIcons.open),
    );
  }
}
