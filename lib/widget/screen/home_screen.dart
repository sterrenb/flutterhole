import 'package:flutter/material.dart';
import 'package:flutterhole/widget/home/sum_builder.dart';
import 'package:flutterhole/widget/home/top_domains_builder.dart';
import 'package:flutterhole/widget/home/top_sources_builder.dart';
import 'package:flutterhole/widget/layout/scaffold.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TabScaffold(
      title: 'Dashboard',
      children: <Widget>[
        SumBuilder(),
//        SummaryBuilder(),
        TopSourcesBuilder(),
        TopDomainsBuilder(),
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
          icon: Icon(Icons.check_circle),
          title: Text('Domains'),
        ),
      ],
    );
  }
}
