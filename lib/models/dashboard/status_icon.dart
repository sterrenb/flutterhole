import 'package:flutter/material.dart';
import 'package:flutter_hole/models/app_state.dart';

const MaterialColor _defaultColor = Colors.grey;

class StatusIcon extends StatelessWidget {
  static MaterialColor color = _defaultColor;

  @override
  Widget build(BuildContext context) {
    final appState = AppState.of(context);

    switch (appState.connected) {
      case true:
        if (!appState.loading)
          color = appState.enabled ? Colors.green : Colors.red;
        break;
      case false:
        color = _defaultColor;
    }

//    if (!appState.loading && appState.connected) {
//      color = appState.enabled ? Colors.green : Colors.orange;
//    }

    return Container(
      child: Icon(
        Icons.brightness_1,
        color: color,
        size: 8.0,
      ),
      padding: EdgeInsets.all(8.0),
    );
  }
}
