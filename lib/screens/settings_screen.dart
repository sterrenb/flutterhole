import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sterrenburg.github.flutterhole/widgets/app_state.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/default_scaffold.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_view.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static int resetCount = 0;
  static final int reset = 5;

  @override
  void dispose() {
    resetCount = 0;
    super.dispose();
  }

  List<Widget> _allPreferenceViews(BuildContext context) {
    return AppState.of(context).allPreferences().map((Preference preference) {
      return PreferenceView(preference: preference);
    }).toList();
  }

//  final List<Widget> piSettings = [
//    PreferenceView(preference: PreferenceIsDark()),
//    PreferenceView(preference: PreferenceHostname()),
//    PreferenceView(preference: PreferencePort()),
//    PreferenceView(preference: PreferenceToken(), addScanButton: true),
//    PreferenceView(preference: PreferenceConfigName()),
//  ];

  @override
  Widget build(BuildContext context) {
    return DefaultScaffold(
      title: 'Settings',
      body: Column(
        children: <Widget>[
          Column(
              children: ListTile.divideTiles(
                  context: context, tiles: _allPreferenceViews(context))
                  .toList()),
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    onPressed: () {
                      if (++resetCount == reset) {
                        resetCount = 0;
                        SharedPreferences.getInstance().then((preferences) {
                          preferences.clear().then((didClear) {
                            if (didClear) {
                              Preference.resetAll();
                              Fluttertoast.showToast(msg: 'Factory reset');
                              AppState.of(context).updateStatus();
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SettingsScreen()));
                            } else {
                              Fluttertoast.showToast(
                                  msg: 'Failed to factory reset');
                            }
                          });
                        });
                      } else {
                        Fluttertoast.showToast(
                            msg:
                            'Press ${reset - resetCount} more times to reset');
                      }
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
