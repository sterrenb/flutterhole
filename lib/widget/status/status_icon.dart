import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/api/status.dart';
import 'package:flutterhole/bloc/api/versions.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/status.dart';
import 'package:flutterhole/model/api/versions.dart';
import 'package:flutterhole/widget/status/circular_percentage_indicator.dart';

class ActiveStatusIcon extends StatefulWidget {
  @override
  _ActiveStatusIconState createState() => _ActiveStatusIconState();
}

class _ActiveStatusIconState extends State<ActiveStatusIcon> {
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
          StatusIcon(color: color),
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

class VersionsStatusIcon extends StatefulWidget {
  @override
  _VersionsStatusIconState createState() => _VersionsStatusIconState();
}

class _VersionsStatusIconState extends State<VersionsStatusIcon> {
  @override
  Widget build(BuildContext context) {
    final versionsBloc = BlocProvider.of<VersionsBloc>(context);
    return BlocBuilder(
      bloc: versionsBloc,
      builder: (BuildContext context, BlocState state) {
        Color color = Colors.grey;

        if (state is BlocStateSuccess<Versions>) {
          color = Colors.green;
        }
        if (state is BlocStateError<Versions>) {
          color = Colors.red;
        }

        return StatusIcon(color: color);
      },
    );
  }

  double _start(StatusStateSleeping state) =>
      1.0 -
          (state.durationRemaining.inMilliseconds /
              state.durationTotal.inMilliseconds);
}

class StatusIcon extends StatelessWidget {
  const StatusIcon({
    Key key,
    @required this.color,
  }) : super(key: key);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Icon(
        Icons.brightness_1,
        color: color,
        size: 8.0,
      ),
    );
  }
}
