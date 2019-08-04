import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartBuilder extends StatefulWidget {
  final Map<String, List<FlSpot>> spots;
  final double maxY;

  double get maxYRounded => (maxY + 50 - (maxY % 50));

  const LineChartBuilder({
    Key key,
    @required this.spots,
    @required this.maxY,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => LineChartBuilderState();
}

class LineChartBuilderState extends State<LineChartBuilder> {
  static final _colors = [
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.indigo,
    Colors.blue,
  ];

  MaterialColor _color(int index) => _colors[index % _colors.length];

  /// The time used as the ending value of the x axis on the line graph.
  final DateTime now = DateTime.now();

  StreamController<LineTouchResponse> controller;

  /// Whether to use the legend, depending on the x axis position
  /// of this legend during the build method.
  bool useLegendTitle;

  @override
  void initState() {
    super.initState();
    controller = StreamController();
    useLegendTitle = true;
  }

  List<LineChartBarData> _lineBarsData() {
    List<LineChartBarData> list = [];
    int i = 0;
    widget.spots.forEach((title, spots) {
      print('parsing spots for $title (${spots.length} spots)');
      i++;
      list.add(LineChartBarData(
        spots: spots,
        isCurved: true,
        colors: [_color(i)],
        belowBarData: BelowBarData(
          show: true,
          colors: [_color(i).withOpacity(0.2)],
        ),
        barWidth: 4.0,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: false,
        ),
      ));
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 4.0),
            child: FlChart(
              chart: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalGrid: true,
                    horizontalInterval: 200.0,
                    verticalInterval: widget.maxYRounded / 4,
                  ),
                  lineTouchData: LineTouchData(
                      touchResponseSink: controller.sink,
                      touchTooltipData: TouchTooltipData(
                          tooltipBgColor: Theme.of(context).cardColor,
                          getTooltipItems: (List<TouchedSpot> touchedSpots) {
                            if (touchedSpots == null) {
                              return null;
                            }

                            return touchedSpots.map((TouchedSpot touchedSpot) {
                              if (touchedSpots == null ||
                                  touchedSpot.spot == null) {
                                return null;
                              }

                              final int yToInt = touchedSpot.spot.y.toInt();
                              if (yToInt == 0) return null;

                              String text = yToInt.toString();

                              final color = touchedSpot.getColor();

                              final int index = _colors.indexOf(color);
                              text = widget.spots.keys.toList()[index] ??
                                  'Unknown';

//                              if (color == _colors.first) text = 'first: $text';
//                              if (color == _colors.last) text = 'last: $text';

                              return TooltipItem(
                                  text,
                                  Theme.of(context).textTheme.caption.copyWith(
                                      color: color,
                                      fontWeight: FontWeight.bold));
                            }).toList();
                          })),
                  titlesData: FlTitlesData(
                    bottomTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      textStyle: Theme.of(context).textTheme.caption,
                      margin: 10,
                      getTitles: (value) {
                        useLegendTitle = !useLegendTitle;
                        if (useLegendTitle) {
                          final index = value / 100;
                          final val =
                              (index + now.hour + 1) % Duration.hoursPerDay;

                          return val.toInt().toString().padLeft(2, '0') + ':00';
                        }

                        return '';
                      },
                    ),
                    leftTitles: SideTitles(
                      showTitles: true,
                      textStyle: TextStyle(
                        color: Color(0xff75729e),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      getTitles: (value) {
                        return value.toInt().toString();
                      },
                      margin: 8,
                      reservedSize: 30,
                    ),
                  ),
                  borderData: buildFlBorderData(Theme.of(context).dividerColor),
                  minX: 0.0,
                  minY: 0.0,
                  maxY: widget.maxY + 20,
                  lineBarsData: _lineBarsData(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  FlBorderData buildFlBorderData(Color color) {
    return FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(
            color: color,
            width: 4,
          ),
          left: BorderSide(
            color: Colors.transparent,
          ),
          right: BorderSide(
            color: Colors.transparent,
          ),
          top: BorderSide(
            color: Colors.transparent,
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
    controller.close();
  }
}
