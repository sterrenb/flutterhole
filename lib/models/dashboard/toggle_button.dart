import 'package:flutter/material.dart';
import 'package:flutter_hole/models/app_state.dart';

class ToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = AppState.of(context);

    if (appState.loading) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: SizedBox(
            child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
            width: 10.0,
            height: 10.0,
          ),
        ),
      );
    }

    final IconData data = appState.enabled ? Icons.pause : Icons.play_arrow;

    final onPressed = appState.connected ? () => appState.toggleStatus() : null;

    return IconButton(
      icon: Icon(data),
      tooltip: 'Enable/disable Pi-hole',
      onPressed: onPressed,
    );
  }
}
