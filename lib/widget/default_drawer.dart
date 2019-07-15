import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole_again/bloc/blacklist/blacklist_bloc.dart';
import 'package:flutterhole_again/bloc/blacklist/blacklist_event.dart';
import 'package:flutterhole_again/bloc/summary/summary_bloc.dart';
import 'package:flutterhole_again/bloc/summary/summary_event.dart';
import 'package:flutterhole_again/bloc/whitelist/whitelist_bloc.dart';
import 'package:flutterhole_again/bloc/whitelist/whitelist_event.dart';
import 'package:flutterhole_again/service/globals.dart';
import 'package:flutterhole_again/service/routes.dart';
import 'package:flutterhole_again/widget/pihole/pihole_list_builder.dart';
import 'package:flutterhole_again/widget/status/status_icon.dart';

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
    final active = Globals.localStorage.active();
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Row(
              children: <Widget>[
                Text(active == null ? 'FlutterHole' : active.title),
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
          _showDetails
              ? Expanded(
            child: PiholeListBuilder(
              editable: false,
            ),
          )
              : _DefaultDrawerMenu(),
        ],
      ),
    );
  }
}

class _DefaultDrawerMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        ListTile(
          title: Text('Dashboard'),
          leading: Icon(Icons.home),
          onTap: () {
            BlocProvider.of<SummaryBloc>(context).dispatch(FetchSummary());
            Globals.router.navigateTo(context, rootPath);
          },
        ),
        ListTile(
          title: Text('Whitelist'),
          leading: Icon(Icons.check_circle),
          onTap: () {
            BlocProvider.of<WhitelistBloc>(context).dispatch(FetchWhitelist());
            Globals.router.navigateTo(context, whitelistPath);
          },
        ),
        ListTile(
          title: Text('Blacklist'),
          leading: Icon(Icons.cancel),
          onTap: () {
            BlocProvider.of<BlacklistBloc>(context).dispatch(FetchBlacklist());
            Globals.router.navigateTo(context, blacklistPath);
          },
        ),
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
