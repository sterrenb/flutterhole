import 'package:flutter/material.dart';
import 'package:flutter_hole/models/dashboard/icon_text.dart';
import 'package:flutter_hole/screens/home_screen.dart';
import 'package:flutter_hole/screens/settings_screen.dart';

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
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Dashboard'),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => HomeScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()));
            },
          )
        ],
      ),
    );
  }
}
