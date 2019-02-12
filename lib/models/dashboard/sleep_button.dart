import 'package:flutter/material.dart';
import 'package:sterrenburg.github.flutterhole/models/app_state.dart';

class SleepButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final int sleeping = AppState.of(context).sleeping;
    return sleeping == 0
        ? ExpansionTile(
            title: Text('Disable',
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600)),
            leading: Icon(
              Icons.stop,
            ),
            initiallyExpanded: true,
            children: <Widget>[
              SleepButton(
                duration: Duration(seconds: 10),
              ),
              SleepButton(
                duration: Duration(seconds: 30),
              ),
              SleepButton(
                duration: Duration(minutes: 5),
              ),
            ],
          )
        : ListTile(
            title: Text('Enable'),
            leading: Icon(Icons.play_arrow),
            onTap: () {
              AppState.of(context).resetSleeping(newStatus: true);
            });
  }
}

class SleepButton extends StatelessWidget {
  final Duration duration;

  const SleepButton({Key key, @required this.duration}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _appState = AppState.of(context);
    Function onPressed = _appState.authorized
        ? () {
            print('click: ${duration.inSeconds}');
            _appState.resetSleeping();
            _appState.disableStatus(duration: duration);
          }
        : null;

    final int seconds = duration.inSeconds;
    String string =
        (seconds < 60) ? '$seconds seconds' : '${seconds ~/ 60} minutes';
    return ListTile(
      title: Text(string),
      leading: Icon(
        Icons.timer,
      ),
      dense: true,
      onTap: onPressed,
      enabled: _appState.authorized,
    );
  }
}
