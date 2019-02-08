import 'package:flutter/material.dart';
import 'package:flutter_hole/models/app_state.dart';
import 'package:flutter_hole/models/dashboard/default_scaffold.dart';
import 'package:flutter_hole/models/preferences/preference.dart';
import 'package:flutter_hole/models/preferences/preference_hostname.dart';
import 'package:flutter_hole/models/preferences/preference_is_dark.dart';
import 'package:flutter_hole/models/preferences/preference_port.dart';
import 'package:flutter_hole/models/preferences/preference_token.dart';
import 'package:flutter_hole/models/preferences/setting_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<Preference> prefList = [
    PreferenceIsDark(),
    PreferenceHostname(),
    PreferencePort(),
    PreferenceToken()
  ];
  final List<Widget> piSettings = [
    SettingWidget(preference: PreferenceIsDark(), type: bool),
    SettingWidget(preference: PreferenceHostname()),
    SettingWidget(preference: PreferencePort(), type: int),
    SettingWidget(preference: PreferenceToken(), addScanButton: true),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultScaffold(
      title: 'Settings',
      body: Column(
        children: <Widget>[
          Column(
              children:
              ListTile.divideTiles(context: context, tiles: piSettings)
                  .toList()),
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    onPressed: () {
                      SharedPreferences.getInstance().then((preferences) {
                        preferences.clear().then((didClear) {
                          if (didClear) {
                            for (Preference preference in prefList) {
                              preference.set(context);
                            }
                            print('yay cleared');
                            AppState.of(context).updateStatus();
                          } else {
                            print('no luck');
                          }
                        });
                      });
                    },
                    child: Text('Reset to default settings'),
                    color: Colors.red,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
