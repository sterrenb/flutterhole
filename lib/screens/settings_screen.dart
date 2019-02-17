import 'package:flutter/material.dart';
import 'package:sterrenburg.github.flutterhole/widgets/app_state.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/buttons/reset_button.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/default_scaffold.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_view.dart';

class SettingsScreen extends StatelessWidget {
  List<Widget> _allPreferenceViews(BuildContext context) {
    return AppState.of(context).allPreferences().map((Preference preference) {
      return PreferenceView(preference: preference);
    }).toList();
  }

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
//          RemoveConfigButton(),
          ResetPrefsButton(),
        ],
      ),
    );
  }
}
