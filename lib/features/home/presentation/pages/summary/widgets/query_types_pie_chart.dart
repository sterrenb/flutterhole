import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/features/api/data/models/dns_query_type.dart';
import 'package:flutterhole/features/home/presentation/pages/summary/notifiers/pie_chart_notifier.dart';
import 'package:provider/provider.dart';
import 'package:supercharged/supercharged.dart';

const double kShowTitleThresholdPercentage = 5.0;

const List<Color> chartColors = [
  Colors.blue,
  Colors.orange,
  Colors.green,
  Colors.red,
  Colors.yellow,
  Colors.purple,
];

class QueryTypesPieChart extends StatelessWidget {
  const QueryTypesPieChart(
    this.dnsQueryTypes, {
    Key key,
  }) : super(key: key);

  final List<DnsQueryType> dnsQueryTypes;

  static Color colorAtIndex(int index) =>
      chartColors.elementAtOrNull(index % chartColors.length);

  @override
  Widget build(BuildContext context) {
    return Consumer<PieChartNotifier>(
      builder: (
        BuildContext context,
        PieChartNotifier notifier,
        _,
      ) {
        return PieChart(PieChartData(
          borderData: FlBorderData(
            show: false,
          ),
          sectionsSpace: (notifier?.selected ?? -1) >= 0 ? 4.0 : 2.0,
          pieTouchData:
              PieTouchData(touchCallback: (PieTouchResponse response) {
            if (response.touchInput is FlLongPressEnd ||
                response.touchInput is FlPanEnd) {
              notifier.selected = -1;
            } else {
              notifier.selected = response.touchedSectionIndex;
            }
          }),
          sections: dnsQueryTypes
              .asMap()
              .map((index, queryType) {
                return MapEntry(
                    index,
                    PieChartSectionData(
                      value: queryType.fraction * 100,
                      title: '${queryType.fraction.toStringAsFixed(0)}%',
                      showTitle:
                          queryType.fraction >= kShowTitleThresholdPercentage,
                      color: colorAtIndex(index),
                      radius: 60 + (notifier.selected == index ? 5.0 : 0.0),
                    ));
              })
              .values
              .toList(),
        ));
      },
    );
  }
}
