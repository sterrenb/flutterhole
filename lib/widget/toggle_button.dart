import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole_again/bloc/status/bloc.dart';

class ToggleButton extends StatelessWidget {
  const ToggleButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final StatusBloc statusBloc = BlocProvider.of<StatusBloc>(context);

    return BlocListener(
      bloc: statusBloc,
      listener: (context, state) {
        if (state is StatusStateEmpty) {
          statusBloc.dispatch(GetStatus());
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
          if (state is StatusStateSuccess) {
            if (state.status.enabled) {
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
          if (state is StatusStateLoading) {
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
          if (state is StatusStateError) {
            return IconButton(
              onPressed: null,
              icon: Icon(Icons.play_arrow),
              tooltip: 'Enable Pi-hole',
            );
          }
          if (state is StatusStateEmpty) {
            return Container();
          }
        },
      ),
    );
  }
}
