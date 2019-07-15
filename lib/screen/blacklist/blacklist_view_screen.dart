import 'package:flutter/material.dart';
import 'package:flutterhole_again/widget/blacklist/blacklist_builder.dart';
import 'package:flutterhole_again/widget/blacklist/blacklist_floating_action_button.dart';
import 'package:flutterhole_again/widget/default_drawer.dart';
import 'package:flutterhole_again/widget/status/status_app_bar.dart';

class BlacklistViewScreen extends StatefulWidget {
  @override
  _BlacklistViewScreenState createState() => _BlacklistViewScreenState();
}

class _BlacklistViewScreenState extends State<BlacklistViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: StatusAppBar(title: 'Blacklist'),
      drawer: DefaultDrawer(),
      floatingActionButton: BlacklistFloatingActionButton(),
      body: BlacklistBuilder(),
    );
  }
}
