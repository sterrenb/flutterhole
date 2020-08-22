import 'package:flutter/material.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/features/routing/presentation/pages/page_scaffold.dart';
import 'package:flutterhole/features/settings/presentation/widgets/preferences/footer_message_string_preference.dart';
import 'package:flutterhole/features/settings/presentation/widgets/preferences/temperature_radio_preference.dart';
import 'package:flutterhole/features/settings/presentation/widgets/preferences/theme_radio_preferences.dart';
import 'package:flutterhole/features/settings/presentation/widgets/preferences/use_numbers_api_switch_preference.dart';
import 'package:flutterhole/widgets/layout/lists/list_title.dart';
import 'package:flutterhole/widgets/layout/notifications/dialogs.dart';

class UserPreferencesPage extends StatefulWidget {
  @override
  _UserPreferencesPageState createState() => _UserPreferencesPageState();
}

class _UserPreferencesPageState extends State<UserPreferencesPage> {
  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      isNested: true,
      appBar: AppBar(
        title: Text('Preferences'),
      ),
      body: ListView(
        children: <Widget>[
          const ListTitle('Customization'),
          ThemeRadioPreferences(),
          const FooterMessageStringPreference(),
          const ListTitle('Data'),
          const UseNumbersApiSwitchPreference(),
          const ListTitle('Temperature'),
          const TemperatureRadioPreference(),
          const ListTitle('Misc'),
          ListTile(
            leading: Icon(KIcons.welcome),
            title: Text('Show welcome message'),
            onTap: () {
              showWelcomeDialog(context);
            },
          ),
        ],
      ),
    );
  }
}
