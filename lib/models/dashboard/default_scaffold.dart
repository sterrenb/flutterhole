import 'package:flutter/material.dart';
import 'package:flutter_hole/models/dashboard/default_drawer.dart';
import 'package:flutter_hole/models/dashboard/icon_text.dart';
import 'package:flutter_hole/models/dashboard/toggle_button.dart';

class DefaultScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const DefaultScaffold({Key key, @required this.title, @required this.body})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: IconText(title: title),
          actions: <Widget>[
            ToggleButton(),
          ],
        ),
        drawer: DefaultDrawer(),
        body: body);
  }
}
