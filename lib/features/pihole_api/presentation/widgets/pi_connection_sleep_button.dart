import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/pihole_api/blocs/pi_connection_bloc.dart';
import 'package:supercharged/supercharged.dart';

enum SleepOption {
  permanently,
  for10seconds,
  for30seconds,
  for5minutes,
  customTime,
}

class _DialogOption extends StatelessWidget {
  const _DialogOption({
    Key key,
    @required this.option,
    @required this.title,
  }) : super(key: key);

  final SleepOption option;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      onTap: () => Navigator.of(context).pop(option),
      title: Text('$title'),
    );
  }
}

class PiConnectionSleepButton extends StatelessWidget {
  Future<void> _showSleepSelectDialog(BuildContext context) async {
    final result = await showDialog<SleepOption>(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Sleep...'),
            children: <Widget>[
              _DialogOption(
                option: SleepOption.permanently,
                title: 'Permanently',
              ),
              _DialogOption(
                option: SleepOption.for10seconds,
                title: 'For 10 seconds',
              ),
              _DialogOption(
                option: SleepOption.for30seconds,
                title: 'For 30 seconds',
              ),
              _DialogOption(
                option: SleepOption.for5minutes,
                title: 'For 5 minutes',
              ),
              _DialogOption(
                option: SleepOption.customTime,
                title: 'Custom time',
              ),
            ],
          );
        });

    switch (result) {
      case SleepOption.permanently:
        getIt<PiConnectionBloc>().add(PiConnectionEvent.disable());
        break;
      case SleepOption.for10seconds:
        getIt<PiConnectionBloc>()
            .add(PiConnectionEvent.sleep(10.seconds, clock.now()));
        break;
      case SleepOption.for30seconds:
        getIt<PiConnectionBloc>()
            .add(PiConnectionEvent.sleep(30.seconds, clock.now()));
        break;
      case SleepOption.for5minutes:
        getIt<PiConnectionBloc>()
            .add(PiConnectionEvent.sleep(5.minutes, clock.now()));
        break;
      case SleepOption.customTime:
        return _showSleepPickerDialog(context);
    }
  }

  Future<void> _showSleepPickerDialog(BuildContext context) async {
    final TimeOfDay result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (result != null) {
      final DateTime now = clock.now();
      final selectedDuration =
          Duration(hours: result.hour, minutes: result.minute);
      final currentDayDuration = Duration(hours: now.hour, minutes: now.minute);
      final difference = selectedDuration - currentDayDuration;

      if (difference == Duration.zero) {
        return;
      }

      Duration totalSleepTime;
      if (difference.isNegative) {
        totalSleepTime = 1.days + difference;
      } else {
        totalSleepTime = difference;
      }

      getIt<PiConnectionBloc>()
          .add(PiConnectionEvent.sleep(totalSleepTime, now));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PiConnectionBloc, PiConnectionState>(
      cubit: getIt<PiConnectionBloc>(),
      builder: (BuildContext context, PiConnectionState state) {
        return IconButton(
          tooltip: 'Sleep',
          icon: Icon(KIcons.sleep),
          onPressed: (state is PiConnectionStateActive)
              ? () async {
//            _showSleepPickerDialog(context);
                  _showSleepSelectDialog(context);
                }
              : null,
        );
      },
    );
  }
}
