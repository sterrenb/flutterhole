import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/api/status.dart';
import 'package:flutterhole/bloc/base/event.dart';
import 'package:flutterhole/bloc/base/state.dart';
import 'package:flutterhole/model/api/status.dart';

class ToggleButton extends StatelessWidget {
  const ToggleButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final StatusBloc statusBloc = BlocProvider.of<StatusBloc>(context);

    return BlocListener(
      bloc: statusBloc,
      listener: (BuildContext context, BlocState state) {
        if (state is BlocStateEmpty<Status>) {
          statusBloc.dispatch(Fetch());
        }
      },
      child: BlocBuilder(
        bloc: statusBloc,
        builder: (context, state) {
          if (state is StatusStateSleeping) {
            return IconButton(
              onPressed: () {
                statusBloc.dispatch(EnableStatus());
              },
              icon: Icon(Icons.play_arrow),
            );
          }
          if (state is BlocStateSuccess<Status>) {
            if (state.data.enabled) {
              return IconButton(
                onPressed: () {
                  statusBloc.dispatch(DisableStatus());
                },
                icon: Icon(Icons.pause),
                tooltip: 'Disable Pi-hole',
              );
            } else {
              return IconButton(
                onPressed: () {
                  statusBloc.dispatch(EnableStatus());
                },
                icon: Icon(Icons.play_arrow),
                tooltip: 'Enable Pi-hole',
              );
            }
          }
          if (state is BlocStateLoading<Status>) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: SizedBox(
                    width: 10.0,
                    height: 10.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )),
              ),
            );
          }
          if (state is BlocStateError<Status>) {
            return IconButton(
              onPressed: () {
                statusBloc.dispatch(Fetch());
              },
              icon: Icon(Icons.error),
              tooltip: 'Get Pi-hole status',
            );
          }

          return IconButton(
            onPressed: () {
              statusBloc.dispatch(Fetch());
            },
            icon: Icon(Icons.refresh),
            tooltip: 'Check Pi-hole status',
          );
        },
      ),
    );
  }
}
