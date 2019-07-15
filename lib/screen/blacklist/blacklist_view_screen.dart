import 'package:flutter/material.dart';
import 'package:flutterhole_again/widget/blacklist/blacklist_builder.dart';
import 'package:flutterhole_again/widget/default_scaffold.dart';

class BlacklistViewScreen extends StatefulWidget {
  @override
  _BlacklistViewScreenState createState() => _BlacklistViewScreenState();
}

class _BlacklistViewScreenState extends State<BlacklistViewScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultScaffold(
      title: 'Blacklist',
      body: BlacklistBuilder(),
    );
  }
}
