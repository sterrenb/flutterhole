import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole_again/bloc/blacklist/blacklist_bloc.dart';
import 'package:flutterhole_again/bloc/blacklist/blacklist_state.dart';
import 'package:flutterhole_again/model/blacklist.dart';
import 'package:flutterhole_again/service/globals.dart';
import 'package:flutterhole_again/service/routes.dart';

class BlacklistFloatingActionButton extends StatefulWidget {
  @override
  _BlacklistFloatingActionButtonState createState() =>
      _BlacklistFloatingActionButtonState();
}

class _BlacklistFloatingActionButtonState
    extends State<BlacklistFloatingActionButton> {
  @override
  Widget build(BuildContext context) {
    final BlacklistBloc blacklistBloc = BlocProvider.of<BlacklistBloc>(context);
    return BlocBuilder(
      bloc: blacklistBloc,
      builder: (context, state) {
        if (state is BlacklistStateSuccess) {
          return FloatingActionButton(
              tooltip: 'Add to blacklist',
              onPressed: () async {
                final BlacklistItem item =
                    await Globals.router.navigateTo(context, blacklistAddPath);
                if (item != null)
                  Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('Added ${item.entry} to blacklist')));
              },
              child: Icon(Icons.add));
        }

        return Container();
      },
    );
  }
}
