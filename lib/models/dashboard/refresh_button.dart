import 'package:flutter/material.dart';
import 'package:sterrenburg.github.flutterhole/models/app_state.dart';

class RefreshButton extends StatelessWidget {
  const RefreshButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.refresh),
      onPressed: () {
        AppState.of(context).updateStatus();
      },
    );
  }
}
