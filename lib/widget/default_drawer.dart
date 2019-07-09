import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole_again/bloc/summary/bloc.dart';
import 'package:flutterhole_again/service/globals.dart';
import 'package:flutterhole_again/service/routes.dart';
import 'package:flutterhole_again/widget/status_icon.dart';

class DefaultDrawer extends StatefulWidget {
  final bool allowConfigSelection;

  const DefaultDrawer({
    Key key,
    this.allowConfigSelection = true,
  }) : super(key: key);

  @override
  _DefaultDrawerState createState() => _DefaultDrawerState();
}

class _DefaultDrawerState extends State<DefaultDrawer> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Row(
              children: <Widget>[
                Text(Globals.localStorage.active().title),
                StatusIcon(),
              ],
            ),
            accountEmail: null,
            onDetailsPressed: widget.allowConfigSelection
                ? () {
                    setState(() {
                      _showDetails = !_showDetails;
                    });
                  }
                : null,
          ),
          Expanded(
            child:
                Center(child: _showDetails ? Text('hi') : _DefaultDrawerMenu()),
          ),
        ],
      ),
    );
  }
}

class _DefaultDrawerMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          title: Text('Dashboard'),
          leading: Icon(Icons.home),
          onTap: () {
            BlocProvider.of<SummaryBloc>(context).dispatch(FetchSummary());
            Globals.router.navigateTo(context, rootPath);
          },
        ),
//        ListTile(
//          title: Text('Whitelist'),
//          leading: Icon(Icons.check_circle),
//          onTap: () => Globals.router.navigateTo(context, Routes.whitelistHome),
//        ),
//        ListTile(
//          title: Text('Blacklist'),
//          leading: Icon(Icons.cancel),
//          onTap: () => Globals.router.navigateTo(context, Routes.blacklistHome),
//        ),
        Divider(),
        ListTile(
          title: Text('Settings'),
          leading: Icon(Icons.settings),
          onTap: () => Globals.router.navigateTo(context, settingsPath),
        ),
        ListTile(
          title: Text('About'),
          leading: Icon(Icons.favorite),
          onTap: () => Globals.router.navigateTo(context, aboutPath),
        ),
      ],
    );
  }
}
