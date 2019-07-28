import 'package:flutter/material.dart';
import 'package:flutterhole/widget/home/chart/queries_over_time_chart_builder.dart';
import 'package:flutterhole/widget/layout/scaffold.dart';

class GraphScreen extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SimpleScaffold(
      title: 'Queries over last 24 hours',
      actions: <Widget>[
        IconButton(
          tooltip: 'Scroll to start',
          icon: Icon(Icons.arrow_left),
          onPressed: () {
            _scrollController.animateTo(
              0.0,
              curve: Curves.easeOut,
              duration: const Duration(milliseconds: 300),
            );
          },
        ),
        IconButton(
          tooltip: 'Scroll to end',
          icon: Icon(Icons.arrow_right),
          onPressed: () {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              curve: Curves.easeOut,
              duration: const Duration(milliseconds: 300),
            );
          },
        ),
      ],
      body: SafeArea(
          minimum: EdgeInsets.only(top: 8.0, right: 8.0, bottom: 8.0),
          child: Scrollbar(
            child: ListView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width * 5,
                      height: MediaQuery.of(context).size.height,
                      child: QueriesOverTimeChartBuilder())
                ]),
          )),
    );
  }
}
