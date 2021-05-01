import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/doughnut_chart.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

List<DoughnutChartData> _createQueryTypesChartData(PiQueryTypes queryTypes) {
  queryTypes.types.removeWhere((key, value) => value <= 0);
  return queryTypes.types.entries
      .map((e) => DoughnutChartData(e.key, e.value))
      .toList();
}

class QueryTypesTile extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final queryTypes = useProvider(queryTypesProvider);

    return Card(
      child: Center(
        child: queryTypes.when(
          data: (types) => DoughnutChart(
            title: 'Query types',
            dataSource: _createQueryTypesChartData(types),
          ),
          loading: () => CircularProgressIndicator(),
          error: (e, s) => Text('${e.toString()}'),
        ),
      ),
    );
  }
}

List<DoughnutChartData> _createForwardDestinationsChartData(
    PiForwardDestinations forwardDestinations) {
  forwardDestinations.destinations.removeWhere((key, value) => value <= 0);
  return forwardDestinations.destinations.entries
      .map((e) => DoughnutChartData(e.key, e.value))
      .toList();
}

List<LineChartData> _createQueriesOverTimeChartData(
    Map<DateTime, int> overTimeData) {
  return overTimeData.entries
      .map((e) => LineChartData(e.key, e.value))
      .toList();
}

class ForwardDestinationsTile extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final forwardDestinations = useProvider(forwardDestinationsProvider);

    return Card(
      child: Center(
        child: forwardDestinations.when(
          data: (destinations) {
            final list = _createForwardDestinationsChartData(destinations);
            return DoughnutChart(
              title: 'Queries answered by',
              dataSource: list,
            );
          },
          loading: () => CircularProgressIndicator(),
          error: (e, s) => Text('${e.toString()}'),
        ),
      ),
    );
  }
}

class LineChartData {
  LineChartData(this.x, this.y, [this.color]);

  final DateTime x;
  final int y;
  final Color color;
}

final format = DateFormat.Hm();

class QueriesOverTimeTile extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final queriesOverTime = useProvider(queriesOverTimeProvider);

    final str = queriesOverTime.maybeWhen(
        data: (e) => '${e.domainsOverTime.keys.first}', orElse: () => '...');

    return Card(
      child: Center(
        child: queriesOverTime.when(
          data: (queries) {
            // if (true && false)
            return SfCartesianChart(
              title: ChartTitle(text: 'Total queries over last 24 hours'),
              primaryXAxis: DateTimeAxis(
                intervalType: DateTimeIntervalType.hours,
                // labelRotation: 45,
                edgeLabelPlacement: EdgeLabelPlacement.shift,
                labelPosition: ChartDataLabelPosition.outside,
                placeLabelsNearAxisLine: false,
              ),
              // tooltipBehavior: TooltipBehavior(enable: true),
              trackballBehavior: TrackballBehavior(
                enable: true,
                lineColor: Colors.green.withOpacity(.8),
                // tooltipAlignment: ChartAlignment.center,
                tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
                // tooltipSettings:
                //     InteractiveTooltip(format: 'point.x : point.y%'),
                markerSettings: TrackballMarkerSettings(
                  markerVisibility: TrackballVisibilityMode.visible,
                  color: Colors.transparent,
                ),
                builder:
                    (BuildContext context, TrackballDetails trackballDetails) {
                  final int totalQueries =
                      trackballDetails.groupingModeInfo.points.first.y;
                  final int blockedQueries =
                      trackballDetails.groupingModeInfo.points.last.y;
                  final double percent = totalQueries == 0
                      ? 0
                      : (blockedQueries / totalQueries) * 100;

                  return Container(
                    width: 150.0,
                    height: 60.0,
                    child: Card(
                      elevation: 8.0,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LegendText(
                                color: Colors.green,
                                text:
                                    'Permitted: ${totalQueries - blockedQueries}'),
                            LegendText(
                                color: Colors.red,
                                text:
                                    'Blocked: $blockedQueries (${percent.toStringAsFixed(2)}%)'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              zoomPanBehavior: ZoomPanBehavior(
                enablePinching: true,
                enablePanning: true,
                // enableSelectionZooming: true,
                zoomMode: ZoomMode.x,
                selectionRectBorderColor: Colors.orange,
              ),
              series: <ChartSeries>[
                AreaSeries<LineChartData, DateTime>(
                  name: 'Total',
                  dataSource:
                      _createQueriesOverTimeChartData(queries.domainsOverTime),
                  xValueMapper: (data, _) => data.x,
                  // '${format.format(data.x.subtract(Duration(minutes: 5)))} - ${format.format(data.x.add(Duration(minutes: 5)))}',
                  yValueMapper: (data, _) => data.y,
                  color: Colors.green[700].withOpacity(.8),
                  borderColor: Colors.green,
                  borderWidth: 1.0,
                ),
                AreaSeries<LineChartData, DateTime>(
                  name: 'Blocked',
                  dataSource:
                      _createQueriesOverTimeChartData(queries.adsOverTime),
                  xValueMapper: (data, _) => data.x,
                  // '${format.format(data.x.subtract(Duration(minutes: 5)))} - ${format.format(data.x.add(Duration(minutes: 5)))}',
                  yValueMapper: (data, _) => data.y,
                  color: Colors.red[700].withOpacity(.8),
                  borderColor: Colors.red,
                  borderWidth: 1.0,
                ),
              ],
            );
          },
          loading: () => CircularProgressIndicator(),
          error: (e, s) => Text('${e.toString()}'),
        ),
      ),
    );
  }
}

class LegendText extends StatelessWidget {
  final Color color;
  final String text;

  const LegendText({
    Key key,
    @required this.color,
    @required this.text,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Icon(KIcons.dot, color: color, size: 4.0),
        ),
        Text(text, style: Theme.of(context).textTheme.caption),
      ],
    );
  }
}
