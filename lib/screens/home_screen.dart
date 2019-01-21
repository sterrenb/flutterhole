import 'package:flutter/material.dart';
import 'package:flutter_hole/models/dashboard/summary_tiles.dart';
import 'package:flutter_hole/models/status_icon.dart';
import 'package:flutter_hole/models/toggle_button.dart';

class HomeScreen extends StatefulWidget {
  final String title;

  const HomeScreen({Key key, this.title}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
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
        body: SummaryTiles());
  }
}
