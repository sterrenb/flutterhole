import 'package:flutter/material.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/features/settings/services/preference_service.dart';
import 'package:preferences/preferences.dart';

class UserPreferencesListTile extends StatelessWidget {
  const UserPreferencesListTile({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PreferencePageLink(
      'Preferences',
      page: PreferencePage([
        SwitchPreference(
          'Use numbers API',
          KPrefs.useNumbersApi,
          defaultVal: true,
        ),
      ]),
      leading: Icon(KIcons.preferences),
      trailing: Icon(KIcons.open),
    );
  }
}
