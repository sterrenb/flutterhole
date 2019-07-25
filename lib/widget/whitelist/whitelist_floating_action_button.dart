import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/api/whitelist.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/whitelist.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/service/routes.dart';
import 'package:persist_theme/data/models/theme_model.dart';
import 'package:provider/provider.dart';

class WhitelistFloatingActionButton extends StatefulWidget {
  @override
  _WhitelistFloatingActionButtonState createState() =>
      _WhitelistFloatingActionButtonState();
}

class _WhitelistFloatingActionButtonState
    extends State<WhitelistFloatingActionButton> {
  @override
  Widget build(BuildContext context) {
    final _theme = Provider.of<ThemeModel>(context);
    final WhitelistBloc whitelistBloc = BlocProvider.of<WhitelistBloc>(context);
    return BlocBuilder(
      bloc: whitelistBloc,
      builder: (context, state) {
        if (state is BlocStateSuccess<Whitelist>) {
          return FloatingActionButton(
              tooltip: 'Add to whitelist',
              backgroundColor: _theme.accentColor,
              onPressed: () async {
                final domain = await Globals.navigateTo(
                  context,
                  whitelistAddPath,
                );
                if (domain != null)
                  Scaffold.of(context).showSnackBar(
                      SnackBar(content: Text('Added $domain to whitelist')));
              },
              child: Icon(Icons.add));
        }

        return Container();
      },
    );
  }
}
