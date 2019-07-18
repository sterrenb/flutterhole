import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/blacklist/bloc.dart';
import 'package:flutterhole/model/blacklist.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/service/routes.dart';
import 'package:persist_theme/data/models/theme_model.dart';
import 'package:provider/provider.dart';

class BlacklistFloatingActionButton extends StatefulWidget {
  @override
  _BlacklistFloatingActionButtonState createState() =>
      _BlacklistFloatingActionButtonState();
}

class _BlacklistFloatingActionButtonState
    extends State<BlacklistFloatingActionButton> {
  @override
  Widget build(BuildContext context) {
    final _theme = Provider.of<ThemeModel>(context);
    final BlacklistBloc blacklistBloc = BlocProvider.of<BlacklistBloc>(context);
    return BlocBuilder(
      bloc: blacklistBloc,
      builder: (context, state) {
        if (state is BlacklistStateSuccess) {
          return FloatingActionButton(
              tooltip: 'Add to blacklist',
              backgroundColor: _theme.accentColor,
              onPressed: () async {
                final BlacklistItem item =
                await Globals.navigateTo(context, blacklistAddPath,);
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
