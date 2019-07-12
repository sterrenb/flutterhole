import 'package:flutter/material.dart';
import 'package:flutterhole_again/widget/default_drawer.dart';
import 'package:flutterhole_again/widget/status/status_app_bar.dart';
import 'package:flutterhole_again/widget/whitelist/whitelist_builder.dart';
import 'package:flutterhole_again/widget/whitelist/whitelist_floating_action_button.dart';

class WhitelistViewScreen extends StatefulWidget {
  @override
  _WhitelistViewScreenState createState() => _WhitelistViewScreenState();
}

class _WhitelistViewScreenState extends State<WhitelistViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: StatusAppBar(title: 'Whitelist'),
      drawer: DefaultDrawer(),
      floatingActionButton: WhitelistFloatingActionButton(),
      body: WhitelistBuilder(),
    );
  }
}
