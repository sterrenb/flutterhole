import 'package:flutter/material.dart';
import 'package:flutterhole/widget/home/chart/clients_over_time_chart_builder.dart';
import 'package:flutterhole/widget/home/chart/queries_over_time_chart_builder.dart';
import 'package:flutterhole/widget/layout/scaffold.dart';

class GraphScreen extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();

  final String title;
  final Widget chartBuilder;
  final int numberOfScreens;

  GraphScreen({Key key,
    @required this.title,
    @required this.chartBuilder,
    this.numberOfScreens = 5})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleScaffold(
      title: title,
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
                      width:
                      MediaQuery
                          .of(context)
                          .size
                          .width * numberOfScreens,
                      height: MediaQuery.of(context).size.height,
                      child: chartBuilder)
                ]),
          )),
    );
  }
}

class QueriesOverTimeGraphScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GraphScreen(
      title: 'Queries over last 24 hours',
      chartBuilder: QueriesOverTimeChartBuilder(),
    );
  }
}

class ClientsOverTimeGraphScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GraphScreen(
      title: 'Clients over last 24 hours',
      chartBuilder: ClientsOverTimeChartBuilder(),
    );
  }
}
