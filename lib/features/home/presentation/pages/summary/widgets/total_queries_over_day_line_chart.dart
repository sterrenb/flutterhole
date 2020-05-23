import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/core/convert.dart';
import 'package:flutterhole/features/home/presentation/pages/summary/widgets/line_chart_scaffold.dart';
import 'package:flutterhole/features/pihole_api/data/models/over_time_data.dart';

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
        titlesData: buildTitlesData(
          context: context,
          getLeftTitles: (double value) {
            return '${value.round()}';
          },
          getBottomTitles: (double value) {
            final dateTime =
                overTimeData.domainsOverTime.keys.elementAt(value.round());

            return '${dateTime.formattedTimeShort}';
          },
        ),
        lineBarsData: <LineChartBarData>[
          LineChartBarData(
            colors: <Color>[KColors.success],
            spots: _spotsFromMap(overTimeData.domainsOverTime),
            barWidth: kLineWidth,
            dotData: FlDotData(
              show: false,
            ),
            belowBarData: buildBarAreaData(KColors.success),
          ),
          LineChartBarData(
            colors: <Color>[KColors.blocked],
            spots: _spotsFromMap(overTimeData.adsOverTime),
            barWidth: kLineWidth,
            dotData: FlDotData(
              show: false,
            ),
            belowBarData: buildBarAreaData(KColors.error),
          ),
        ],
        gridData: buildGridData(),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Theme.of(context).cardColor,
            getTooltipItems: (List<LineBarSpot> touchedSpots) =>
                buildLineTooltipItems(
                    context: context,
                    touchedSpots: touchedSpots,
                    lineTooltipTextBuilder: (int index, Color color, double y) {
                      if (color == KColors.success) {
                        return 'Permitted: ${y.round()}';
                      } else if (color == KColors.blocked) {
                        return 'Blocked:  ${y.round()}';
                      } else {
                        return 'Unknown: ${y.round()}';
                      }
                    }),
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
