import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/features/home/presentation/pages/summary/widgets/line_chart_scaffold.dart';
import 'package:flutterhole/features/pihole_api/data/models/over_time_data_clients.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_client.dart';
import 'package:supercharged/supercharged.dart';

const List<Color> _colors = [
  Colors.blue,
  Colors.orange,
  Colors.green,
  Colors.red,
  Colors.yellow,
  Colors.purple,
];

class ClientsOverDayLineChart extends StatelessWidget {
  const ClientsOverDayLineChart(
    this.overTimeData, {
    Key key,
  }) : super(key: key);

  final OverTimeDataClients overTimeData;

  Color _indexToColor(int index) => _colors.elementAt(index % (_colors.length));

  Map<PiClient, List<int>> _buildClientHitsMap() {
    Map<PiClient, List<int>> map = {};

    overTimeData.clients.forEachIndexed((
      int index,
      PiClient client,
    ) {
      map.putIfAbsent(client, () => []);
    });

    overTimeData.data.forEach((
      DateTime timestamp,
      List<int> hitsPerClient,
    ) {
      hitsPerClient.forEachIndexed((index, hits) {
        final indexedClient = overTimeData.clients.elementAt(index);

        map[indexedClient].add(hits);
      });
    });

    return map;
  }

  List<FlSpot> _spotsFromHits(List<int> allHits) {
    List<FlSpot> spots = [];

    allHits.forEachIndexed((int index, int hits) {
      spots.add(FlSpot(index.toDouble(), hits.toDouble()));
    });

    return spots;
  }

  List<LineChartBarData> _buildLineChartBarData() {
    List<LineChartBarData> results = [];

    final Map<PiClient, List<int>> map = _buildClientHitsMap();

    map.forEach((PiClient client, List<int> hits) {
      final list = _spotsFromHits(hits);

      final color = _indexToColor(overTimeData.clients.indexOf(client));
      results.add(LineChartBarData(
        colors: <Color>[color],
        spots: list,
        barWidth: kLineWidth,
        dotData: FlDotData(
          show: false,
        ),
        belowBarData: buildBarAreaData(color),
      ));
    });

    return results;
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
            return '';
          },
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Theme
                .of(context)
                .cardColor,
            getTooltipItems: (List<LineBarSpot> touchedSpots) =>
                buildLineTooltipItems(
                  context: context,
                  showTooltipWhenZero: false,
                  touchedSpots: touchedSpots,
                  lineTooltipTextBuilder: (int index,
                      Color color,
                      double y,) {
                    return '${overTimeData.clients
                        .elementAt(index)
                        .nameOrIp}: $y';
                  },
                ),
          ),
        ),
        lineBarsData: _buildLineChartBarData(),
        gridData: buildGridData(),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
