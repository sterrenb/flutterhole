import 'package:flutter/material.dart';
import 'package:flutterhole_again/widget/scaffold.dart';
import 'package:flutterhole_again/widget/whitelist/whitelist_builder.dart';
import 'package:flutterhole_again/widget/whitelist/whitelist_floating_action_button.dart';

class WhitelistViewScreen extends StatefulWidget {
  @override
  _WhitelistViewScreenState createState() => _WhitelistViewScreenState();
}

class _WhitelistViewScreenState extends State<WhitelistViewScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultScaffold(
      title: 'Whitelist',
      body: WhitelistBuilder(),
      floatingActionButton: WhitelistFloatingActionButton(),
    );
  }
}
