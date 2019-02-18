import 'package:flutter/material.dart';
import 'package:sterrenburg.github.flutterhole/widgets/app_state.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/buttons/reset_button.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/default_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultScaffold(
      title: 'Settings',
      body: Column(
        children: <Widget>[
          Column(
              children: ListTile.divideTiles(
                  context: context,
                  tiles: AppState.of(context).allPreferenceViews(context))
                  .toList()),
//          RemoveConfigButton(),
          ResetPrefsButton(),
        ],
      ),
    );
  }
}
