import 'package:flutter/material.dart';
import 'package:flutterhole_web/settings.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: AppSettingsList(),
    );
  }
}
