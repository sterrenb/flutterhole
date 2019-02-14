import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:sterrenburg.github.flutterhole/models/app_state.dart';

class SleepButtons extends StatefulWidget {
  @override
  SleepButtonsState createState() {
    return new SleepButtonsState();
  }
}

class SleepButtonsState extends State<SleepButtons> {
  static bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AppState.of(context).isSleeping()
        ? ExpansionTile(
      title: Text('Disable',
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600)),
      leading: Icon(
        Icons.pause,
      ),
      initiallyExpanded: isExpanded,
      onExpansionChanged: (bool value) => isExpanded = value,
      backgroundColor: Theme
          .of(context)
          .dividerColor,
      children: <Widget>[
        SleepButtonPermanent(),
        SleepButton(
          duration: Duration(seconds: 10),
        ),
        SleepButton(
          duration: Duration(seconds: 30),
        ),
        SleepButton(
          duration: Duration(minutes: 5),
        ),
        SleepButtonCustom(),
      ],
    )
        : ListTile(
        title: Text('Enable'),
        leading: Icon(Icons.timer_off),
        onTap: () {
          isExpanded = false;
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
    Function _onTap = _appState.authorized
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
      onTap: _onTap,
      enabled: _appState.authorized,
    );
  }
}

class SleepButtonPermanent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _appState = AppState.of(context);
    return ListTile(
      title: Text('Permanently'),
      leading: Icon(
        Icons.stop,
      ),
      dense: true,
      onTap: () => _appState.disableStatus(duration: Duration()),
      enabled: _appState.authorized,
    );
  }
}

class SleepButtonCustom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _appState = AppState.of(context);
    Function _onTap = _appState.authorized
        ? () {
      final picker = Picker(
          title: Text('Select a sleep duration'),
          textAlign: TextAlign.center,
          confirmText: 'OK',
          adapter: NumberPickerAdapter(data: [
            NumberPickerColumn(
                begin: 0, end: 60, initValue: 5, suffix: Text(' sec')),
            NumberPickerColumn(begin: 0, end: 60, suffix: Text(' min')),
          ]),
//                adapter: NumberPickerAdapter(data: [
//                  NumberPickerColumn(
//                      begin: 0, end: 60, initValue: 5, suffix: Text(' sec')),
//                  NumberPickerColumn(begin: 0, end: 60, suffix: Text(' min')),
//                ]),
          delimiter: [
            PickerDelimiter(
              child: Center(child: Text(':')),
            )
          ],
          onConfirm: (Picker picker, List value) {
            print(value.toString());
            List<int> values = picker.getSelectedValues();
            _appState.resetSleeping();
            _appState.disableStatus(
                duration:
                Duration(seconds: values[0], minutes: values[1]));
          },
          hideHeader: true);
      picker.showDialog(context);
//      _appState.resetSleeping();
//      _appState.disableStatus(duration: duration);
    }
        : null;

    return ListTile(
      title: Text('Custom time'),
      leading: Icon(
        Icons.av_timer,
      ),
      dense: true,
      onTap: _onTap,
      enabled: AppState
          .of(context)
          .authorized,
    );
  }
}
