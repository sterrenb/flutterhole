import 'package:flutter/material.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/core/convert.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/settings/presentation/notifiers/theme_mode_notifier.dart';
import 'package:flutterhole/features/settings/presentation/widgets/pihole_theme_builder.dart';
import 'package:flutterhole/features/settings/services/preference_service.dart';
import 'package:flutterhole/widgets/layout/dialogs.dart';
import 'package:flutterhole/widgets/layout/list_title.dart';
import 'package:flutterhole/widgets/layout/snackbars.dart';
import 'package:preferences/preferences.dart';
import 'package:provider/provider.dart';

enum _PopupOption {
  reset,
}

class _PopupMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_PopupOption>(
      onSelected: (option) async {
        switch (option) {
          case _PopupOption.reset:
            await getIt<PreferenceService>().reset();
            showInfoSnackBar(context, 'Preferences reset',
                duration: Duration(seconds: 2));
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<_PopupOption>>[
        const PopupMenuItem(
          child: Text('Reset my preferences'),
          value: _PopupOption.reset,
        ),
      ],
    );
  }
}

class UserPreferencesPage extends StatefulWidget {
  @override
  _UserPreferencesPageState createState() => _UserPreferencesPageState();
}

class _UserPreferencesPageState extends State<UserPreferencesPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModeNotifier>(
      builder: (BuildContext context,
          ThemeModeNotifier notifier,
          _,) {
        return PiholeThemeBuilder(
          child: Scaffold(
            appBar: AppBar(
              title: Text('Preferences'),
              actions: <Widget>[
                // TODO this throws some exceptions from ThemeModeNotifier after clearing and re-opening the page
                // _PopupMenu(),
              ],
            ),
            body: ListView(
              children: <Widget>[
                ListTitle('Customization'),
                RadioPreference(
                  '${ThemeModeEnumMap[ThemeMode.system].capitalize} theme',
                  '${ThemeModeEnumMap[ThemeMode.system]}',
                  KPrefs.themeMode,
                  isDefault: true,
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
                ListTitle('Data'),
                SwitchPreference(
                  'Use numbers API',
                  KPrefs.useNumbersApi,
                  defaultVal: true,
                  desc:
                  'If enabled, the dashboard will fetch number trivia from the Numbers API.',
                ),
                ListTitle('Misc'),
                ListTile(
                  leading: Icon(KIcons.welcome),
                  title: Text('Show welcome message'),
                  onTap: () {
                    showWelcomeDialog(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
