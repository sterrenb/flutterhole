import 'package:flutter/material.dart';
import 'package:sterrenburg.github.flutterhole/widgets/app_state.dart';

/// A button that updates the Pi-hole status on tap.
class RefreshButton extends StatelessWidget {
  const RefreshButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.refresh),
      tooltip: 'Refresh you Pi-hole status',
      onPressed: () {
        AppState.of(context).updateStatus();
      },
    );
  }
}
