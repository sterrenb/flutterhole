import 'package:charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:pihole_api/pihole_api.dart';

import 'chart_helpers.dart';

class ClientActivityBarChart extends StatelessWidget {
  const ClientActivityBarChart(
    this.activity, {
    Key? key,
  }) : super(key: key);

  final PiClientActivityOverTime activity;

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> data = <BarChartGroupData>[];
    int i = 0;
    for (MapEntry<DateTime, List<int>> entry in activity.activity.entries) {
      final counts = entry.value;

      double fromY = 0.0;
      int rodCount = 0;
      final rods = counts.map((count) {
        final rod = BarChartRodStackItem(fromY, fromY + count,
            Colors.primaries.elementAt(rodCount % Colors.primaries.length));
        fromY += count;
        rodCount++;
        return rod;
      }).toList();

      final group = BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            y: counts.reduce((value, element) => value + element).toDouble(),
            rodStackItems: rods,
            // borderRadius: BorderRadius.zero,
            width: 2.0,
          ),
        ],
      );

      data.add(group);
      i++;
    }

    return StackedBarChart(
      data: data,
      getTooltipItem: (context, index, rod) {
        // TODO show useful tooltip
        return BarTooltipItem('hi there', Theme.of(context).textTheme.caption!);
      },
      getBottomTitle: (value) {
        final date = activity.activity.keys.elementAt(value.round());
        return getBottomTitleFromDate(date);
      },
      horizontalInterval: 50.0,
    );
  }
}
