import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutterhole/bloc/api/status.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/status.dart';
import 'package:flutterhole/service/converter.dart';

/// A list of [SleepButton], [SleepButtonPermanent], and [SleepButtonCustom].
class SleepButtons extends StatefulWidget {
  @override
  SleepButtonsState createState() {
    return new SleepButtonsState();
  }
}

class SleepButtonsState extends State<SleepButtons> {
  /// The local store of the expanded state, to maintain state between builds.
  static bool isExpanded = false;

  Status _cache;

  /// The timer that triggers a build every second.
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final StatusBloc statusBloc = BlocProvider.of<StatusBloc>(context);
    return BlocBuilder(
      bloc: statusBloc,
      builder: (BuildContext context, BlocState state) {
        if (state is StatusStateSleeping) {
          return ListTile(
              title: Text(
                  'Wake (${durationToTimeString(state.durationRemaining)})'),
              leading: Icon(Icons.timer_off),
              onTap: () {
                statusBloc.dispatch(EnableStatus());
              });
        }
        if (state is BlocStateSuccess<Status> ||
            state is BlocStateLoading<Status>) {
          if (state is BlocStateSuccess<Status>) {
            _cache = state.data;
          }

          if (_cache != null && _cache.enabled) {
            return ExpansionTile(
              title: Text('Disable',
                  style:
                  TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600)),
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
                  onDispatch: _shrink,
                ),
                SleepButton(
                  duration: Duration(seconds: 30),
                  onDispatch: _shrink,
                ),
                SleepButton(
                  duration: Duration(minutes: 5),
                  onDispatch: _shrink,
                ),
                SleepButtonCustom(),
              ],
            );
          } else {
            return ListTile(
                title: Text('Enable'),
                leading: Icon(Icons.timer_off),
                onTap: () {
                  statusBloc.dispatch(EnableStatus());
                });
          }
        }

        return ListTile(
          title: Text(
            'Disable',
            style: TextStyle(color: Theme
                .of(context)
                .textTheme
                .caption
                .color),
          ),
          leading: Icon(Icons.pause,
              color: Theme
                  .of(context)
                  .textTheme
                  .caption
                  .color),
        );
      },
    );
  }

  void _shrink() {
    setState(() {
      isExpanded = false;
    });
  }
}

/// A button that puts the Pi-hole to sleep for a fixed specified [duration] on tap.
class SleepButton extends StatelessWidget {
  /// The amount of time for the Pi-hole to sleep.
  final Duration duration;

  final VoidCallback onDispatch;

  const SleepButton(
      {Key key, @required this.duration, @required this.onDispatch})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final StatusBloc statusBloc = BlocProvider.of<StatusBloc>(context);
    final int seconds = duration.inSeconds;

    String string = (seconds < Duration.secondsPerMinute)
        ? '$seconds seconds'
        : '${seconds ~/ Duration.secondsPerMinute} minutes';
    return ListTile(
        title: Text(string),
        leading: Icon(
          Icons.timer,
        ),
        dense: true,
        onTap: () {
          statusBloc.dispatch(SleepStatus(duration));
          onDispatch();
        });
  }
}

/// A button that puts the Pi-hole to sleep indefinitely on tap.
class SleepButtonPermanent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final StatusBloc statusBloc = BlocProvider.of<StatusBloc>(context);

    return ListTile(
      title: Text('Permanently'),
      leading: Icon(
        Icons.stop,
      ),
      dense: true,
      onTap: () => statusBloc.dispatch(DisableStatus()),
    );
  }
}

/// A button that puts the Pi-hole to sleep for a used specified [duration] on tap.
///
/// Uses the [Picker] for user input.
class SleepButtonCustom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final StatusBloc statusBloc = BlocProvider.of<StatusBloc>(context);

    return ListTile(
      title: Text('Custom time'),
      leading: Icon(
        Icons.av_timer,
      ),
      dense: true,
      onTap: () {
        final picker = Picker(
            title: Column(
              children: <Widget>[
                Text('Select a sleep duration'),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    '(h:m:s)',
                    style: Theme.of(context).textTheme.subtitle,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            confirmText: 'OK',
            textStyle: Theme.of(context).textTheme.title,
            backgroundColor: Theme.of(context).dialogBackgroundColor,
            adapter: NumberPickerAdapter(data: [
              NumberPickerColumn(
                  begin: 0,
                  end: Duration.hoursPerDay - 1,
                  onFormatValue: (val) => val.toString().padLeft(2, '0')),
              NumberPickerColumn(
                  begin: 0,
                  end: Duration.minutesPerHour - 1,
                  onFormatValue: (val) => val.toString().padLeft(2, '0')),
              NumberPickerColumn(
                  begin: 0,
                  end: Duration.secondsPerMinute - 1,
                  onFormatValue: (val) => val.toString().padLeft(2, '0')),
            ]),
            delimiter: [
              PickerDelimiter(
                child: Center(child: Text(':')),
              ),
              PickerDelimiter(
                column: 3,
                child: Center(child: Text(':')),
              )
            ],
            onConfirm: (Picker picker, List value) {
              List<int> values = picker.getSelectedValues();
              statusBloc.dispatch(SleepStatus(Duration(
                hours: values[0],
                minutes: values[1],
                seconds: values[2],
              )));
            },
            hideHeader: true);
        picker.showDialog(context);
      },
//      enabled: AppState.of(context).authorized,
    );
  }
}
