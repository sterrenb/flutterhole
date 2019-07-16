import 'package:flutter/material.dart';
import 'package:flutterhole_again/widget/default_drawer.dart';
import 'package:flutterhole_again/widget/settings/settings_builder.dart';
import 'package:flutterhole_again/widget/status/status_app_bar.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: StatusAppBar(
          title: 'Settings',
        ),
        drawer: DefaultDrawer(
          allowConfigSelection: false,
        ),
        body: SettingsBuilder());
  }
}
