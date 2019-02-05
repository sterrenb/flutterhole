import 'package:flutter/material.dart';
import 'package:flutter_hole/models/dashboard/default_scaffold.dart';
import 'package:flutter_hole/models/preferences/preference_brightness.dart';
import 'package:flutter_hole/models/preferences/preference_hostname.dart';
import 'package:flutter_hole/models/preferences/preference_port.dart';
import 'package:flutter_hole/models/preferences/preference_token.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<Widget> piSettings = [
    SwitchListTile(
      title: Text('Dark theme'),
      value: false,
      onChanged: (bool value) {
        print('yay');
      },
      secondary: Icon(Icons.lightbulb_outline),
    ),
    PreferenceBrightness().settingsWidget(),
    PreferenceHostname().settingsWidget(),
    PreferencePort().settingsWidget(),
    PreferenceToken().settingsWidget(),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultScaffold(
      title: 'Settings',
      body: Column(
        children: ListTile.divideTiles(context: context, tiles: piSettings)
            .toList(),
      ),
    );
  }
}
