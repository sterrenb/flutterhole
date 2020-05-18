import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/core/convert.dart';
import 'package:flutterhole/features/pihole_api/data/models/over_time_data.dart';

const double _horizontalLineInterval = 100.0;
const double _verticalLineInterval = 30.0;
const double _lineWidth = 2.0;

class TotalQueriesOverDayLineChart extends StatelessWidget {
  const TotalQueriesOverDayLineChart(
    this.overTimeData, {
    Key key,
  }) : super(key: key);

  final OverTimeData overTimeData;

  List<FlSpot> _spotsFromMap(Map<DateTime, int> map) {
    List<FlSpot> spots = [];
    int index = 0;

    map.forEach((DateTime timestamp, int hits) {
      spots.add(FlSpot(index.toDouble(), hits.toDouble()));
      index++;
    });

    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          leftTitles: SideTitles(
            textStyle: Theme.of(context).textTheme.caption,
            showTitles: true,
            interval: _horizontalLineInterval,
            getTitles: (double value) {
              return '${value.round()}';
            },
          ),
          bottomTitles: SideTitles(
              showTitles: true,
              interval: _verticalLineInterval,
              textStyle: Theme.of(context).textTheme.caption,
              getTitles: (double value) {
                final dateTime =
                    overTimeData.domainsOverTime.keys.elementAt(value.round());

                return '${dateTime.formattedTimeShort}';
              }),
        ),
        lineBarsData: <LineChartBarData>[
          LineChartBarData(
            colors: <Color>[KColors.success],
            spots: _spotsFromMap(overTimeData.domainsOverTime),
            barWidth: _lineWidth,
            dotData: FlDotData(
              show: false,
            ),
            belowBarData: BarAreaData(
              show: true,
              colors: <Color>[
                KColors.success.withOpacity(0.5),
                KColors.success.withOpacity(0.25),
              ],
              gradientColorStops: [0.5, 1.0],
              gradientFrom: const Offset(0, 0),
              gradientTo: const Offset(0, 1),
            ),
          ),
          LineChartBarData(
            colors: <Color>[KColors.blocked],
            spots: _spotsFromMap(overTimeData.adsOverTime),
            barWidth: _lineWidth,
            dotData: FlDotData(
              show: false,
            ),
            belowBarData: BarAreaData(
              show: true,
              colors: <Color>[
                KColors.blocked.withOpacity(0.5),
                KColors.blocked.withOpacity(0.25),
              ],
              gradientColorStops: [0.5, 1.0],
              gradientFrom: const Offset(0, 0),
              gradientTo: const Offset(0, 1),
            ),
          ),
        ],
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          checkToShowHorizontalLine: (double value) {
            return value.round() % _horizontalLineInterval == 0;
          },
          checkToShowVerticalLine: (double value) {
            return value.round() % _verticalLineInterval == 0;
          },
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Theme.of(context).cardColor,
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              if (touchedSpots == null) {
                return null;
              }

              return touchedSpots.map((LineBarSpot touchedSpot) {
                if (touchedSpot == null) {
                  return null;
                }

                final Color color = touchedSpot.bar.colors[0];

                if (color == KColors.success) {
                  return LineTooltipItem(
                    'Permitted: ${touchedSpot.y.round()}',
                    Theme.of(context).textTheme.bodyText1.apply(
                          color: color,
                        ),
                  );
                } else if (color == KColors.blocked) {
                  return LineTooltipItem(
                    'Blocked:  ${touchedSpot.y.round()}',
                    Theme.of(context).textTheme.bodyText1.apply(
                          color: color,
                        ),
                  );
                }

                return LineTooltipItem(
                  '${touchedSpot.y.round()}',
                  Theme.of(context).textTheme.bodyText1.apply(
                        color: color,
                      ),
                );
              }).toList();
            },
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
