import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole_again/bloc/status/status_bloc.dart';
import 'package:flutterhole_again/bloc/status/status_state.dart';

import 'circular_percentage_indicator.dart';

class StatusIcon extends StatefulWidget {
  @override
  _StatusIconState createState() => _StatusIconState();
}

class _StatusIconState extends State<StatusIcon> {
  @override
  Widget build(BuildContext context) {
    final StatusBloc statusBloc = BlocProvider.of<StatusBloc>(context);
    return BlocBuilder(
      bloc: statusBloc,
      builder: (context, state) {
        Color color = Colors.grey;

        if (state is StatusStateSuccess) {
          color = Colors.green;
          if (state.status.disabled) {
            color = Colors.orange;
          }
        }
        if (state is StatusStateError) {
          color = Colors.red;
        }
        if (state is StatusStateSleeping) {
          color = Colors.orange;
        }

        return Stack(alignment: AlignmentDirectional.center, children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.brightness_1,
              color: color,
              size: 8.0,
            ),
          ),
          (state is StatusStateSleeping)
              ? ConstrainedBox(
                  constraints: BoxConstraints.loose(Size.fromRadius(8.0)),
                  child: CircularPercentageIndicator(
                    duration: state.durationTotal,
                    start: (state.durationRemaining.inMilliseconds /
                        state.durationTotal.inMilliseconds),
                    color: color,
                  ))
              : Container(),
        ]);
      },
    );
  }
}
