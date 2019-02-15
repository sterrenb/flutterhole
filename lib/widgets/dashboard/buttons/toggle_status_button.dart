import 'package:flutter/material.dart';
import 'package:sterrenburg.github.flutterhole/widgets/app_state.dart';

/// A button that allows users to toggle (enable/disable) the Pi-hole.
class ToggleStatusButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _appState = AppState.of(context);

    if (_appState.loading) {
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

    final IconData _data = _appState.enabled ? Icons.pause : Icons.play_arrow;

    Function onPressed =
        _appState.authorized ? () => _appState.toggleStatus() : null;

    final _enableDisablePiHole = 'Enable/disable Pi-hole';
    return IconButton(
      icon: Icon(_data),
      tooltip: _enableDisablePiHole,
      onPressed: onPressed,
    );
  }
}
