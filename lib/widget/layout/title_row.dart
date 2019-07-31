import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/pihole/bloc.dart';
import 'package:flutterhole/widget/status/status_icon.dart';

class TitleRow extends StatelessWidget {
  const TitleRow({
    Key key,
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
              print('active in blocbuilder: ${state.active}');
              text = state.active.title;
            }
            return Text(
              text,
              overflow: TextOverflow.fade,
            );
          },
        )),
        StatusIcon(),
      ],
    );
  }
}
