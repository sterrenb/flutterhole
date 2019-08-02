import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/pihole/bloc.dart';
import 'package:flutterhole/widget/status/status_icon.dart';

class TitleIconRow extends StatelessWidget {
  final String title;

  const TitleIconRow({
    Key key,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Flexible(
            child: BlocBuilder(
          bloc: BlocProvider.of<PiholeBloc>(context),
          builder: (context, state) {
            String text = 'FlutterHole';
            if (state is PiholeStateSuccess) {
              text = state.active.title;
            }
            return Text(
              title ?? text,
              overflow: TextOverflow.fade,
            );
          },
        )),
        ActiveStatusIcon(),
      ],
    );
  }
}
