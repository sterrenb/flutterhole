import 'package:flutter/material.dart';
import 'package:flutterhole_web/settings.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: AppSettingsList(),
    );
  }
}
