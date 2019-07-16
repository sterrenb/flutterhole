import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole_again/bloc/blacklist/blacklist_bloc.dart';
import 'package:flutterhole_again/bloc/blacklist/blacklist_event.dart';
import 'package:flutterhole_again/bloc/query/query_bloc.dart';
import 'package:flutterhole_again/bloc/query/query_event.dart';
import 'package:flutterhole_again/bloc/summary/summary_bloc.dart';
import 'package:flutterhole_again/bloc/summary/summary_event.dart';
import 'package:flutterhole_again/bloc/whitelist/whitelist_bloc.dart';
import 'package:flutterhole_again/bloc/whitelist/whitelist_event.dart';
import 'package:flutterhole_again/model/pihole.dart';
import 'package:flutterhole_again/service/globals.dart';
import 'package:flutterhole_again/service/routes.dart';
import 'package:flutterhole_again/widget/pihole/pihole_list_builder.dart';
import 'package:flutterhole_again/widget/status/sleep_button.dart';
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

  Pihole active;

  @override
  void initState() {
    super.initState();
    active = Globals.localStorage.active();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Row(
              children: <Widget>[
                Flexible(
                    child: Text(
                  active == null ? 'FlutterHole' : active.title,
                      overflow: TextOverflow.fade,
                    )),
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
              ? PiholeListBuilder(
            editable: false,
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
    return Column(
//      padding: EdgeInsets.zero,
//      shrinkWrap: true,
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
        SleepButtons(),
        ListTile(
          title: Text('Query Log'),
          leading: Icon(Icons.filter_list),
          onTap: () {
            BlocProvider.of<QueryBloc>(context)
                .dispatch(FetchQueries());
            Globals.router.navigateTo(context, queryPath);
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
