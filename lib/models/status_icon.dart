import 'package:flutter/material.dart';
import 'package:flutter_hole/app_state.dart';

const MaterialColor _defaultColor = Colors.grey;

class StatusIcon extends StatelessWidget {
  static MaterialColor color = _defaultColor;

  @override
  Widget build(BuildContext context) {
    final appState = AppState.of(context);

    if (!appState.statusLoading) {
      color = appState.status ? Colors.green : Colors.red;
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
