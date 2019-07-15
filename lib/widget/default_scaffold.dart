import 'package:flutter/material.dart';
import 'package:flutterhole_again/widget/default_drawer.dart';
import 'package:flutterhole_again/widget/default_end_drawer.dart';
import 'package:flutterhole_again/widget/status/status_app_bar.dart';

class DefaultScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const DefaultScaffold({
    Key key,
    @required this.title,
    @required this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: StatusAppBar(title: title),
      drawer: DefaultDrawer(),
      endDrawer: DefaultEndDrawer(),
      body: body,
    );
  }
}
