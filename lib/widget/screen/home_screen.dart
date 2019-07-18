import 'package:flutter/material.dart';
import 'package:flutterhole/widget/dashboard/summary_builder.dart';
import 'package:flutterhole/widget/dashboard/top_sources_builder.dart';
import 'package:flutterhole/widget/layout/scaffold.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TabScaffold(
      title: 'Dashboard',
      children: <Widget>[
        SummaryBuilder(),
        TopSourcesBuilder(),
        Center(child: Text('Coming soon')),
      ],
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text('Summary'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.computer),
          title: Text('Clients'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.cancel),
          title: Text('Blocked domains'),
        ),
      ],
    );
  }
}
