import 'package:flutter/material.dart';
import 'package:sterrenburg.github.flutterhole/models/dashboard/default_scaffold.dart';
import 'package:sterrenburg.github.flutterhole/models/dashboard/summary_tiles.dart';

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
