import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/services/api_service.dart';
import 'package:flutterhole/widgets/dashboard/dashboard_card.dart';
import 'package:flutterhole/widgets/ui/cache.dart';
import 'package:pihole_api/pihole_api.dart';

List<Color> gradientColors = [
  Colors.green,
  Colors.green,
];

class QueriesOverTimeTile extends StatelessWidget {
  const QueriesOverTimeTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CacheBuilder<PiQueriesOverTime>(
      provider: activeQueriesOverTimeProvider,
      builder: (context, queries, isLoading, error) {
        return DashboardCard(
          id: DashboardID.queriesOverTime,
          // header: DashboardCardHeader(
          //   title: DashboardID.queriesOverTime.humanString,
          //   isLoading: isLoading,
          //   error: error,
          // ),
          content: AnimatedCardContent(
            isLoading: isLoading,
            child: queries == null
                ? Container()
                : Stack(
                    children: [
                      DashboardCardHeader(
                        title: DashboardID.queriesOverTime.humanString,
                        isLoading: isLoading,
                        error: error,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 45.0,
                          right: 30.0,
                        ),
                        child: Builder(builder: (context) {
                          // DateTime valueToKey(double value) =>
                          //     queries.domainsOverTime.keys
                          //         .elementAt(value.toInt());

                          return LineChart(
                            LineChartData(
                                borderData: FlBorderData(show: false),
                                titlesData: FlTitlesData(
                                  show: true,
                                  topTitles: AxisTitles(),
                                  rightTitles: AxisTitles(),
                                  // bottomTitles: AxisTitles(
                                  //   // TODO docs 0.50 migration
                                  //   getTitles: (double value) {
                                  //     return valueToKey(value).hm;
                                  //   },
                                  //   checkToShowTitle: (double minValue,
                                  //       double maxValue,
                                  //       SideTitles sideTitles,
                                  //       double appliedInterval,
                                  //       double value) {
                                  //     return value % 2 == 0;
                                  //   },
                                  // ),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  // drawHorizontalLine: true,
                                  drawVerticalLine: false,
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                    dotData: FlDotData(show: false),
                                    // TODO use LinearGradient class
                                    // colors: gradientColors,

                                    belowBarData: BarAreaData(
                                      show: true,
                                      // colors: [
                                      //   gradientColors.last.withOpacity(.2)
                                      // ],
                                      // colors: [
                                      //   gradientColors.last.withOpacity(.5),
                                      //   gradientColors.first.withOpacity(0),
                                      // ],
                                      // gradientColorStops: [0.0, 1.0],
                                      // gradientFrom: const Offset(0, 0),
                                      // gradientTo: const Offset(0, 1),
                                    ),
                                    preventCurveOverShooting: true,
                                    barWidth: 2.0,
                                    isStrokeCapRound: true,
                                    isCurved: true,
                                    spots: queries.domainsOverTime.entries
                                        .toList()
                                        .asMap()
                                        .entries
                                        .map<FlSpot>((e) => FlSpot(
                                            e.key.toDouble(),
                                            e.value.value.toDouble()))
                                        .toList(),
                                  )
                                ]),
                            swapAnimationDuration: kThemeAnimationDuration * 2,
                            swapAnimationCurve: Curves.easeOutCubic,
                          );
                        }),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class Charty extends StatelessWidget {
  const Charty({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
