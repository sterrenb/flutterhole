import 'package:flutter/material.dart';
import 'package:flutter_hole/models/default_scaffold.dart';
import 'package:flutter_hole/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultScaffold(
      title: 'Settings',
      body: Column(
        children: <Widget>[
          PrefHostname().settingsWidget(),
          PrefPort().settingsWidget(),
        ],
      ),
    );
  }
}
