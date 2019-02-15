import 'package:flutter/material.dart';
import 'package:sterrenburg.github.flutterhole/models/dashboard/sleep_button.dart';
import 'package:sterrenburg.github.flutterhole/models/dashboard/status_title.dart';
import 'package:sterrenburg.github.flutterhole/screens/about_screen.dart';
import 'package:sterrenburg.github.flutterhole/screens/home_screen.dart';
import 'package:sterrenburg.github.flutterhole/screens/recently_blocked_screen.dart';
import 'package:sterrenburg.github.flutterhole/screens/settings_screen.dart';

/// The menu entry widget in a [DefaultDrawer].
class DrawerTile extends StatelessWidget {
  /// The screen to navigate to on tap.
  final Widget onTapScreen;

  /// The human friendly title.
  final String title;

  /// The leading material icon.
  ///
  /// ```dart
  /// iconData = Icons.home;
  /// ```
  final IconData iconData;

  const DrawerTile(
      {Key key,
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

/// The default drawer menu, containing a [ListView] of [DrawerTile]s.
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
                child: StatusTitle(
                  title: 'FlutterHole',
                )),
          ),
          DrawerTile(
              onTapScreen: HomeScreen(),
              title: 'Dashboard',
              iconData: Icons.home),
          SleepButtons(),
          DrawerTile(
              onTapScreen: RecentlyBlockedScreen(),
              title: 'Recently Blocked',
              iconData: Icons.block),
          DrawerTile(
              onTapScreen: SettingsScreen(),
              title: 'Settings',
              iconData: Icons.settings),
          DrawerTile(
              onTapScreen: AboutScreen(),
              title: 'About',
              iconData: Icons.favorite),
        ],
      ),
    );
  }
}
