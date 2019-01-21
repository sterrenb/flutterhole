import 'package:flutter/material.dart';
import 'package:flutter_hole/models/dashboard/summary_tiles.dart';
import 'package:flutter_hole/models/default_scaffold.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultScaffold(
      title: 'FlutterHole',
      body: SummaryTiles(),
    );
  }
}
