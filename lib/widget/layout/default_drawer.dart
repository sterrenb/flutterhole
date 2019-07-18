import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/blacklist/bloc.dart';
import 'package:flutterhole/bloc/query/bloc.dart';
import 'package:flutterhole/bloc/summary/bloc.dart';
import 'package:flutterhole/bloc/top_sources/bloc.dart';
import 'package:flutterhole/bloc/whitelist/bloc.dart';
import 'package:flutterhole/model/pihole.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/service/routes.dart';
import 'package:flutterhole/widget/pihole/pihole_list_builder.dart';
import 'package:flutterhole/widget/status/sleep_button.dart';
import 'package:flutterhole/widget/status/status_icon.dart';

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
      children: <Widget>[
        ListTile(
          title: Text('Dashboard'),
          leading: Icon(Icons.home),
          onTap: () {
            BlocProvider.of<SummaryBloc>(context).dispatch(FetchSummary());
            BlocProvider.of<TopSourcesBloc>(context).dispatch(
                FetchTopSources());
            Globals.navigateTo(context, homePath);
          },
        ),
        ListTile(
          title: Text('Whitelist'),
          leading: Icon(Icons.check_circle),
          onTap: () {
            BlocProvider.of<WhitelistBloc>(context).dispatch(FetchWhitelist());
            Globals.navigateTo(context, whitelistPath);
          },
        ),
        ListTile(
          title: Text('Blacklist'),
          leading: Icon(Icons.cancel),
          onTap: () {
            BlocProvider.of<BlacklistBloc>(context).dispatch(FetchBlacklist());
            Globals.navigateTo(context, blacklistPath);
          },
        ),
        SleepButtons(),
        ListTile(
          title: Text('Query Log'),
          leading: Icon(Icons.filter_list),
          onTap: () {
            BlocProvider.of<QueryBloc>(context).dispatch(FetchQueries());
            BlocProvider.of<BlacklistBloc>(context).dispatch(FetchBlacklist());
            Globals.navigateTo(context, queryPath);
          },
        ),
        Divider(),
        ListTile(
          title: Text('Settings'),
          leading: Icon(Icons.settings),
          onTap: () => Globals.navigateTo(context, settingsPath),
        ),
        ListTile(
          title: Text('About'),
          leading: Icon(Icons.favorite),
          onTap: () => Globals.navigateTo(context, aboutPath),
        ),
      ],
    );
  }
}
