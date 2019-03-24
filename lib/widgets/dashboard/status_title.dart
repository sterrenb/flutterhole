import 'package:flutter/material.dart';
import 'package:sterrenburg.github.flutterhole/widgets/app_state.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/status_icon.dart';

/// A widget creating a [Row] of a [StatusIcon] and [Text] with a [title].
class StatusTitle extends StatelessWidget {
  const StatusTitle({
    Key key,
    this.title,
  }) : super(key: key);

  /// The human friendly title.
  final String title;

  _durationToString(Duration duration) {
    return duration.inHours.toString() +
        ':' +
        (duration.inMinutes % Duration.minutesPerHour)
            .toString()
            .padLeft(2, '0') +
        ':' +
        (duration.inSeconds % Duration.secondsPerMinute)
            .toString()
            .padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.of(context);
    String timerString = appState.isSleeping()
        ? ''
        : ' (' + _durationToString(appState.sleeping) + ')';
    return Row(
      children: <Widget>[
        StatusIcon(),
        title == null
            ? FutureBuilder<String>(
          future: appState.piConfig.getActiveString(),
          builder: (context, snapshot) {
            if (snapshot.hasData) return Text(snapshot.data);

            return Text('');
          },
        )
            : Text(title),
        Opacity(
            opacity: 0.75,
            child: Text(
              timerString,
              style: TextStyle(fontWeight: FontWeight.w400),
            )),
      ],
    );
  }
}
