import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/pihole_api/blocs/pi_connection_bloc.dart';
import 'package:supercharged/supercharged.dart';

class PiConnectionSleepButton extends StatelessWidget {
  Future<void> _showSleepDialog(BuildContext context) async {
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
      bloc: getIt<PiConnectionBloc>(),
      builder: (BuildContext context, PiConnectionState state) {
        return IconButton(
          tooltip: 'Sleep',
          icon: Icon(KIcons.sleep),
          onPressed: (state is PiConnectionStateActive)
              ? () async {
                  _showSleepDialog(context);
                }
              : null,
        );
      },
    );
  }
}
