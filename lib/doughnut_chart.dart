import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DoughnutChartData {
  DoughnutChartData(this.x, this.y, [this.color]);

  final String x;
  final double y;
  final Color color;
}

class DoughnutChart extends StatelessWidget {
  const DoughnutChart({
    Key key,
    @required this.title,
    @required this.dataSource,
  }) : super(key: key);

  final String title;
  final List<DoughnutChartData> dataSource;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SfCircularChart(
        title: ChartTitle(
          text: title,
          // text: 'Query types: ${queryTypes}',
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          format: 'point.x: point.y%',
        ),
        legend: Legend(
          isVisible: true,
          overflowMode: LegendItemOverflowMode.scroll,
        ),
        palette: Colors.primaries.reversed.toList(),
        series: <CircularSeries>[
          DoughnutSeries<DoughnutChartData, String>(
            // dataSource: chartData,
            dataSource: dataSource,
            xValueMapper: (data, _) => data.x,
            yValueMapper: (data, _) => data.y,
            dataLabelMapper: (data, _) => '${data.y.round()}%',
            enableSmartLabels: true,
            groupMode: CircularChartGroupMode.value,
            groupTo: 2.0,
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              // labelPosition: ChartDataLabelPosition.outside,
              useSeriesColor: true,
              // labelIntersectAction: LabelIntersectAction.none,
            ),
            // explode: true,
            legendIconType: LegendIconType.circle,
            animationDuration:
                kThemeAnimationDuration.inMilliseconds.toDouble(),
          )
        ],
      ),
    );
  }
}
