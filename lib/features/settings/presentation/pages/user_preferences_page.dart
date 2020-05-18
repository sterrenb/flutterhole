import 'package:flutter/material.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/features/settings/presentation/notifiers/theme_mode_notifier.dart';
import 'package:flutterhole/features/settings/presentation/widgets/pihole_theme_builder.dart';
import 'package:flutterhole/features/settings/presentation/widgets/preferences/theme_radio_preferences.dart';
import 'package:flutterhole/features/settings/presentation/widgets/preferences/use_numbers_api_switch_preference.dart';
import 'package:flutterhole/widgets/layout/dialogs.dart';
import 'package:flutterhole/widgets/layout/list_title.dart';
import 'package:provider/provider.dart';

class UserPreferencesPage extends StatefulWidget {
  @override
  _UserPreferencesPageState createState() => _UserPreferencesPageState();
}

class _UserPreferencesPageState extends State<UserPreferencesPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModeNotifier>(
      builder: (
        BuildContext context,
        ThemeModeNotifier notifier,
        _,
      ) {
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
                ThemeRadioPreferences(),
                ListTitle('Data'),
                UseNumbersApiSwitchPreference(),
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
