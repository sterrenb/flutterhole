import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

const double kLineWidth = 2.0;
const double kHorizontalLineInterval = 100.0;
const double kVerticalLineInterval = 30.0;

class LineChartScaffold extends StatelessWidget {
  const LineChartScaffold({
    Key key,
    @required this.title,
    @required this.lineChart,
  }) : super(key: key);

  final String title;
  final Widget lineChart;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              '$title',
              style: TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: lineChart,
          ),
        ],
      ),
    );
  }
}

FlTitlesData buildTitlesData({
  @required BuildContext context,
  @required GetTitleFunction getLeftTitles,
  @required GetTitleFunction getBottomTitles,
}) {
  return FlTitlesData(
    leftTitles: SideTitles(
      textStyle: Theme.of(context).textTheme.caption,
      showTitles: true,
      interval: kHorizontalLineInterval,
      getTitles: getLeftTitles,
    ),
    bottomTitles: SideTitles(
      showTitles: true,
      interval: kVerticalLineInterval,
      textStyle: Theme.of(context).textTheme.caption,
      getTitles: getBottomTitles,
    ),
  );
}
