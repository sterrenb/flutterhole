import 'package:flutter/material.dart';
import 'package:sterrenburg.github.flutterhole/models/app_state.dart';
import 'package:sterrenburg.github.flutterhole/models/dashboard/status_icon.dart';

/// A widget creating a [Row] of a [StatusIcon] and [Text] with a [title].
class StatusTitle extends StatelessWidget {
  const StatusTitle({
    Key key,
    @required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final int sleeping = AppState
        .of(context)
        .sleeping;
    String titleWithTimer = sleeping == 0 ? title : title +
        (' (' + sleeping.toString() + 's)');
    return Row(
      children: <Widget>[
        StatusIcon(),
        Text(titleWithTimer),
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () {
            AppState.of(context).updateStatus();
          },
        ),
      ],
    );
  }
}
