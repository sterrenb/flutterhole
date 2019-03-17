import 'package:flutter/material.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/buttons/reset_button.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/default_scaffold.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_api_path.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_config_name.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_hostname.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_is_dark.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_port.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_ssl.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_token.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_view.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultScaffold(
      title: 'Settings',
        body: ListView(
        children: <Widget>[
          ListTab('Pi-hole configuration'),
          PreferenceViewString(PreferenceHostname()),
          PreferenceViewString(PreferencePort()),
          PreferenceViewString(PreferenceToken()),
          PreferenceViewString(PreferenceConfigName()),
          Divider(),
          ListTab('Advanced'),
          PreferenceViewBool(PreferenceSSL()),
          PreferenceViewString(PreferenceApiPath()),
          Divider(),
          ListTab('Miscellaneous'),
          PreferenceViewBool(PreferenceIsDark()),
          ResetPrefsButton(),
        ],
        )
    );
  }
}

class ListTab extends StatelessWidget {
  final String text;

  const ListTab(this.text);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(text, style: Theme
          .of(context)
          .textTheme
          .subtitle
          .copyWith(color: Colors.blue)),
    );
  }
}

//List<Widget> allPreferenceViews(BuildContext context) {
//  return AppState.of(context).allPreferences().map((Preference preference) {
//    switch (preference.defaultValue.runtimeType) {
//      case bool:
//        return PreferenceViewBool(preference: preference);
//      default:
//        return PreferenceViewString(preference: preference);
//    }
//  }).toList();
//}
