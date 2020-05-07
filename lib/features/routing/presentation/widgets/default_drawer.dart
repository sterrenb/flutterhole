import 'package:alice/alice.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/routing/presentation/widgets/drawer_tile.dart';
import 'package:flutterhole/features/routing/services/router_service.dart';
import 'package:flutterhole/features/settings/presentation/widgets/default_drawer_header.dart';




class DefaultDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DefaultDrawerHeader(),
          DrawerTile(
            routeName: RouterService.home,
            title: Text('Dashboard'),
            icon: Icon(KIcons.dashboard),
          ),
          DrawerTile(
            routeName: RouterService.settings,
            title: Text('Settings'),
            icon: Icon(KIcons.settings),
          ),
          Divider(),
          DrawerTile(
            routeName: RouterService.about,
            title: Text('About'),
            icon: Icon(KIcons.about),
          ),
          ListTile(
            title: Text('API Log'),
            leading: Icon(KIcons.log),
            onTap: () {
              getIt<Alice>().showInspector();
            },
          ),
        ],
      ),
    );
  }
}
