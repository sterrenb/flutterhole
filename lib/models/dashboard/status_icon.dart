import 'package:flutter/material.dart';
import 'package:flutter_hole/models/app_state.dart';

const MaterialColor _defaultColor = Colors.grey;

/// A widget that displays whether the Pi-hole® is enabled (green), disabled (red), or unknown (grey).
class StatusIcon extends StatelessWidget {
  static MaterialColor color = _defaultColor;

  @override
  Widget build(BuildContext context) {
    final appState = AppState.of(context);

    print('connected: ${appState.connected}');
    switch (appState.connected) {
      case true:
        if (!appState.loading)
          color = appState.enabled ? Colors.green : Colors.red;
        break;
      case false:
        color = _defaultColor;
    }

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
