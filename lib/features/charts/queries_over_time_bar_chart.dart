import 'package:charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole_web/features/formatting/date_formatting.dart';
import 'package:pihole_api/pihole_api.dart';

import 'chart_helpers.dart';

class QueriesOverTimeBarChart extends StatelessWidget {
  const QueriesOverTimeBarChart(
    this.queriesOverTime, {
    Key? key,
  }) : super(key: key);

  final PiQueriesOverTime queriesOverTime;

  @override
  Widget build(BuildContext context) {
    List<int> domainValues = queriesOverTime.domainsOverTime.values.toList();
    List<int> adValues = queriesOverTime.adsOverTime.values.toList();
    List<DateTime> domainKeys = queriesOverTime.domainsOverTime.keys.toList();

    List<BarChartGroupData> data = <BarChartGroupData>[];

    BarTooltipItem getTooltipItem(
        BuildContext context, int index, BarChartRodData rod) {
      final ads = rod.rodStackItems.first.toY;
      final domains = rod.rodStackItems.last.toY;
      final date = domainKeys.elementAt(index);
      return BarTooltipItem(
        '',
        Theme.of(context).textTheme.caption!,
        textAlign: TextAlign.start,
        children: [
          TextSpan(
            text: '${date.beforeAfter(const Duration(minutes: 5))}\n',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const TextSpan(text: 'Permitted: '),
          TextSpan(
            text: '${(domains - ads).round()}\n',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const TextSpan(text: 'Blocked: '),
          TextSpan(
              text: ads.round().toString(),
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              )),
          TextSpan(text: ' (${((ads / domains) * 100).toStringAsFixed(1)}%)'),
        ],
      );
    }

    for (MapEntry<int, DateTime> entry in domainKeys.asMap().entries
        // .toList().sublist(0, 5)
        ) {
      final int index = entry.key;

      final totalValue = domainValues.elementAt(index);
      final adValue = adValues.elementAt(index);
      final group = BarChartGroupData(x: index, barRods: [
        BarChartRodData(
          y: totalValue.toDouble(),
          rodStackItems: [
            BarChartRodStackItem(0.0, adValue.toDouble(), Colors.red),
            BarChartRodStackItem(
                adValue.toDouble(), totalValue.toDouble(), Colors.green),
          ],
          width: 2.0,
          borderRadius: BorderRadius.zero,
        ),
      ]);

      data.add(group);
    }

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: StackedBarChart(
        data: data,
        getTooltipItem: getTooltipItem,
        horizontalInterval: 50.0,
        getBottomTitle: (value) {
          final date = domainKeys.elementAt(value.round());
          return getBottomTitleFromDate(date);
        },
        // checkToShowHorizontalLine: (value) => value % 50 == 0,
      ),
    );
  }
}
