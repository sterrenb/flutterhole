import 'package:flutter/material.dart';
import 'package:flutter_hole/models/preferences/preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// a scaffold for managing a preference that is saved between sessions, using [SharedPreferences].
class PreferenceBrightness extends Preference {
  PreferenceBrightness()
      : super(
            key: 'brightness',
            title: 'Dark Theme',
            description: 'Use the global dark theme',
            help: Container(),
            iconData: Icons.lightbulb_outline,
            onSet: (bool didSet, BuildContext context) {
              print('ok');
            });

  @override
  Widget settingsWidget() {
    return FutureBuilder<bool>(
        future: getBool(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            return SwitchListTile(
              title: Text(title),
              value: snapshot.data,
              secondary: Icon(iconData),
              onChanged: (bool value) {
                setBool(value, context).then((bool didSet) {
                  if (didSet) {
                    print('yay');
                  }
                });
              },
            );
          }

          return Center(child: CircularProgressIndicator());
        });
  }
}
