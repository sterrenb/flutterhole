import 'package:flutter/material.dart';
import 'package:flutterhole_again/widget/default_scaffold.dart';
import 'package:flutterhole_again/widget/whitelist/whitelist_builder.dart';

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
    );
  }
}
