import 'package:flutter/material.dart';
import 'package:flutter_hole/models/dashboard/icon_text.dart';
import 'package:flutter_hole/screens/home_screen.dart';
import 'package:flutter_hole/screens/recently_blocked_screen.dart';
import 'package:flutter_hole/screens/settings_screen.dart';

class _drawerTile extends StatelessWidget {
  final Widget screen;
  final String title;
  final IconData iconData;

  const _drawerTile(
      {Key key, @required this.screen, @required this.title, @required this.iconData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(iconData),
      title: Text(title),
      onTap: () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => screen));
      },
    );
  }

}

class DefaultDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Container(
                alignment: Alignment.bottomLeft,
                padding: EdgeInsets.only(bottom: 4.0),
//                child: AppTitle(),
                child: IconText(
                  title: 'FlutterHole',
                )),
          ),
          _drawerTile(
              screen: HomeScreen(), title: 'Dashboard', iconData: Icons.home),
          _drawerTile(screen: RecentlyBlockedScreen(),
              title: 'Recently Blocked',
              iconData: Icons.block),
          _drawerTile(screen: SettingsScreen(),
              title: 'Settings',
              iconData: Icons.settings),
        ],
      ),
    );
  }
}
