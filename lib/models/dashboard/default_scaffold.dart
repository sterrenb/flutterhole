import 'package:flutter/material.dart';
import 'package:flutter_hole/models/dashboard/default_drawer.dart';
import 'package:flutter_hole/models/dashboard/status_title.dart';
import 'package:flutter_hole/models/dashboard/toggle_status_button.dart';

/// The default scaffold, using the [DefaultDrawer] and the [ToggleStatusButton].
class DefaultScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const DefaultScaffold({Key key, @required this.title, @required this.body})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: StatusTitle(title: title),
          actions: <Widget>[
            ToggleStatusButton(),
          ],
        ),
        drawer: DefaultDrawer(),
        body: body);
  }
}
