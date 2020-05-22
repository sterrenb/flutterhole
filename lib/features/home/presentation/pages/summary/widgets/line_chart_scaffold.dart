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
}) =>
    FlTitlesData(
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

FlGridData buildGridData() => FlGridData(
      show: true,
      drawVerticalLine: true,
      checkToShowHorizontalLine: (double value) {
        return value.round() % kHorizontalLineInterval == 0;
      },
      checkToShowVerticalLine: (double value) {
        return value.round() % kVerticalLineInterval == 0;
      },
    );

BarAreaData buildBarAreaData(Color color) => BarAreaData(
      show: true,
      colors: <Color>[
        color.withOpacity(0.5),
        color.withOpacity(0.25),
      ],
      gradientColorStops: [0.5, 1.0],
      gradientFrom: const Offset(0, 0),
      gradientTo: const Offset(0, 1),
    );

typedef String LineTooltipTextBuilder(int index, Color color, double y);

List<LineTooltipItem> buildLineTooltipItems({
  BuildContext context,
  List<LineBarSpot> touchedSpots,
  bool showTooltipWhenZero = true,
  LineTooltipTextBuilder lineTooltipTextBuilder,
}) {
  if (touchedSpots == null) {
    return null;
  }

  return touchedSpots.map((LineBarSpot touchedSpot) {
    if (touchedSpot == null) {
      return null;
    }

    final Color color = touchedSpot.bar.colors[0];

    final text = lineTooltipTextBuilder(
      touchedSpot.barIndex,
      color,
      touchedSpot.y,
    );

    if (!showTooltipWhenZero && touchedSpot.y == 0) return null;

    return LineTooltipItem(
      '$text',
      Theme.of(context).textTheme.bodyText1.apply(
            color: color,
          ),
    );
  }).toList();
}
