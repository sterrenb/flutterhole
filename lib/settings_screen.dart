import 'package:flutter/material.dart';
import 'package:flutterhole_web/pi_temperature_text.dart';
import 'package:flutterhole_web/settings.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Settings  '),
            PiTemperatureText(),
          ],
        ),
      ),
      body: AppSettingsList(),
    );
  }
}
