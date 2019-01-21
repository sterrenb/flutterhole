import 'package:flutter/material.dart';
import 'package:flutter_hole/models/status_icon.dart';
import 'package:flutter_hole/models/toggle_button.dart';

class DefaultScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const DefaultScaffold({Key key, @required this.title, @required this.body})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              StatusIcon(),
              Text(title),
            ],
          ),
          actions: <Widget>[
            ToggleButton(),
          ],
        ),
        body: body);
  }
}
