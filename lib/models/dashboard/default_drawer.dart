import 'package:flutter/material.dart';
import 'package:flutter_hole/models/dashboard/status_title.dart';
import 'package:flutter_hole/screens/home_screen.dart';
import 'package:flutter_hole/screens/recently_blocked_screen.dart';
import 'package:flutter_hole/screens/settings_screen.dart';

/// The menu entry widget in a [DefaultDrawer].
class DrawerTile extends StatelessWidget {
  /// The screen to navigate to on tap.
  final Widget onTapScreen;
  final String title;
  final IconData iconData;

  const DrawerTile({Key key,
    @required this.onTapScreen,
    @required this.title,
    @required this.iconData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(iconData),
      title: Text(title),
      onTap: () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => onTapScreen));
      },
    );
  }
}

/// The default drawer menu, containing a list of [DrawerTile]s.
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
                child: StatusTitle(
                  title: 'FlutterHole',
                )),
          ),
          DrawerTile(
              onTapScreen: HomeScreen(),
              title: 'Dashboard',
              iconData: Icons.home),
          DrawerTile(
              onTapScreen: RecentlyBlockedScreen(),
              title: 'Recently Blocked',
              iconData: Icons.block),
          DrawerTile(
              onTapScreen: SettingsScreen(),
              title: 'Settings',
              iconData: Icons.settings),
        ],
      ),
    );
  }
}
