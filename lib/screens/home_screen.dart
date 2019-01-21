import 'package:flutter/material.dart';
import 'package:flutter_hole/app_state_container.dart';
import 'package:flutter_hole/models/StatusIcon.dart';
import 'package:flutter_hole/models/ToggleButton.dart';

class HomeScreen extends StatefulWidget {
  final String title;

  const HomeScreen({Key key, this.title}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final x = AppState.of(context);
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              StatusIcon(),
              Text(widget.title),
            ],
          ),
          actions: <Widget>[
            ToggleButton(),
          ],
        ),
        body: Text('status: ${x.status}'));
  }
}
