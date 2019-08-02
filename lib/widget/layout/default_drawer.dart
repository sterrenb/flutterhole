import 'package:flutter/material.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/service/routes.dart';
import 'package:flutterhole/widget/layout/title_row.dart';
import 'package:flutterhole/widget/pihole/pihole_list_builder.dart';
import 'package:flutterhole/widget/status/sleep_button.dart';

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
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: TitleIconRow(),
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
            Globals.navigateTo(context, homePath);
          },
        ),
        ListTile(
          title: Text('Whitelist'),
          leading: Icon(Icons.check_circle),
          onTap: () {
            Globals.navigateTo(context, whitelistViewPath);
          },
        ),
        ListTile(
          title: Text('Blacklist'),
          leading: Icon(Icons.cancel),
          onTap: () {
            Globals.navigateTo(context, blacklistViewPath);
          },
        ),
        SleepButtons(),
        ListTile(
          title: Text('Query Log'),
          leading: Icon(Icons.filter_list),
          onTap: () {
            Globals.navigateTo(context, queryViewPath);
          },
        ),
        Divider(),
        ListTile(
            title: Text('Settings'),
            leading: Icon(Icons.settings),
            onTap: () {
              Globals.navigateTo(context, settingsPath);
            }),
        ListTile(
          title: Text('Internal Log'),
          leading: Icon(Icons.format_list_bulleted),
          onTap: () => Globals.navigateTo(context, logPath),
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
