import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/api/status.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/status.dart';
import 'package:flutterhole/widget/status/circular_percentage_indicator.dart';

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
      builder: (BuildContext context, BlocState state) {
        Color color = Colors.grey;

        if (state is BlocStateSuccess<Status>) {
          color = Colors.green;
          if (state.data.disabled) {
            color = Colors.orange;
          }
        }
        if (state is BlocStateError<Status>) {
          color = Colors.red;
        }
        if (state is StatusStateSleeping) {
          color = Colors.orange;
        }

        return Stack(alignment: AlignmentDirectional.center, children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
                    start: _start(state),
                    color: color,
                  ))
              : Container(),
        ]);
      },
    );
  }

  double _start(StatusStateSleeping state) =>
      1.0 -
          (state.durationRemaining.inMilliseconds /
              state.durationTotal.inMilliseconds);
}
