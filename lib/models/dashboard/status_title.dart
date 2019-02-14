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

  _durationToString(Duration duration) {
    return duration.inHours.toString() + ':' +
        (duration.inMinutes % Duration.minutesPerHour).toString().padLeft(
            2, '0') + ':' +
        (duration.inSeconds % Duration.secondsPerMinute).toString().padLeft(
            2, '0');
  }

  @override
  Widget build(BuildContext context) {
    final _appState = AppState.of(context);
    String timerString = _appState.isSleeping()
        ? ''
        : ' (' + _durationToString(_appState.sleeping) + ')';
    return Row(
      children: <Widget>[
        StatusIcon(),
        Text(title),
        Text(timerString, style: TextStyle(color: Theme
            .of(context)
            .accentColor),),
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
