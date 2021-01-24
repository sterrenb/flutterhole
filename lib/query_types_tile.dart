import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartData {
  ChartData(this.x, this.y, [this.color]);

  final String x;
  final double y;
  final Color color;
}

final List<ChartData> chartData = [
  // ChartData('Pie', 25.1),
  // ChartData('Cool', 15.2),
  // ChartData('Nuts', 35.3),
  // ChartData('More', 25),
  ChartData('A', 12.4),
  ChartData('B', 23.5),
  ChartData('C', 34.6),
  ChartData('D', 45.7),
];
final x = Legend();

class QueryTypesTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Center(
        child: SfCircularChart(
          title: ChartTitle(
            text: 'Query types',
          ),
          tooltipBehavior: TooltipBehavior(
            enable: true,
            format: 'point.x: point.y%',
          ),
          legend: Legend(
            isVisible: true,
          ),
          series: <CircularSeries>[
            DoughnutSeries<ChartData, String>(
              dataSource: chartData,
              xValueMapper: (data, _) => data.x,
              yValueMapper: (data, _) => data.y,
              dataLabelMapper: (data, _) => '${data.y.toStringAsFixed(1)}%',
              dataLabelSettings: DataLabelSettings(isVisible: false),
              // explode: true,
              legendIconType: LegendIconType.circle,
              animationDuration:
                  kThemeAnimationDuration.inMilliseconds.toDouble(),
            )
          ],
        ),
      ),
    );
  }
}
