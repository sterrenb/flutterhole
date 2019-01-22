// Inspired by https://gist.github.com/slightfoot/d549282ac0a5466505db8ffa92279d25

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class Pref {
  final String key;
  final String title;
  final IconData iconData;

  Pref({@required this.key, @required this.title, @required this.iconData});

  static final Future<SharedPreferences> _sharedPreferences =
      SharedPreferences.getInstance();

  Widget _defaultSettingsWidget() {
    return FutureBuilder<String>(
        future: get(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          return (snapshot.hasData)
              ? ListTile(
                  leading: Icon(iconData),
                  title: Text(title),
                  subtitle: Text(snapshot.data),
                )
              : Container();
        });
  }

  Widget settingsWidget() => _defaultSettingsWidget();

  Future<String> get() async {
    (await _sharedPreferences).setString(key, 'pi.hole');
    return (await _sharedPreferences).get(key).toString();
  }
}

class PrefHostname extends Pref {
  PrefHostname()
      : super(key: 'hostname', title: 'Hostname', iconData: Icons.home);
}

class PrefPort extends Pref {
  PrefPort() : super(key: 'port', title: 'Port', iconData: Icons.adjust);
}
