import 'package:charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:pihole_api/pihole_api.dart';

import 'chart_helpers.dart';

class _TooltipItem {
  const _TooltipItem(this.client, this.count, this.color);

  final PiClientName client;
  final int count;
  final Color color;
}

class ClientActivityBarChart extends StatelessWidget {
  const ClientActivityBarChart(
    this.activity, {
    Key? key,
  }) : super(key: key);

  static final List<Color> colors = Colors.primaries;

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> data = <BarChartGroupData>[];
    int i = 0;
    for (MapEntry<DateTime, List<int>> entry in activity.activity.entries) {
      final counts = entry.value;

      double fromY = 0.0;
      int rodCount = 0;
      final rods = counts.map((count) {
        final rod = BarChartRodStackItem(
            fromY, fromY + count, colors.elementAt(rodCount % colors.length));
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
        List<_TooltipItem> items = [];

        final hits = activity.activity.values.elementAt(index);
        final total = hits.reduce((value, element) => value + element);
        print('$total: $hits');

        for (MapEntry<int, int> entry in hits.asMap().entries) {
          if (entry.value > 0) {
            final client = activity.clients.elementAt(entry.key);
            // items.add('${client.ip}: ${entry.value}');
            items.add(_TooltipItem(client, entry.value,
                colors.elementAt(entry.key % colors.length)));
          }
        }

        items.sort((a, b) => b.count - a.count);

        final date = activity.activity.keys.elementAt(index);
        return BarTooltipItem(
          '',
          Theme.of(context).textTheme.caption!,
          textAlign: TextAlign.start,
          children: [
            TextSpan(
              text: '${getDateRangeStringFromDate(date)}\n',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            ...items
                .map((e) => TextSpan(
                        text: e.client.name.isNotEmpty
                            ? e.client.name
                            : e.client.ip,
                        style: TextStyle(color: e.color),
                        children: [
                          TextSpan(
                            text: ': ${e.count}\n',
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ]))
                .toList(),
          ],
        );
      },
      getBottomTitle: (value) {
        final date = activity.activity.keys.elementAt(value.round());
        return getBottomTitleFromDate(date);
      },
      horizontalInterval: 50.0,
    );
  }

  final PiClientActivityOverTime activity;
}
