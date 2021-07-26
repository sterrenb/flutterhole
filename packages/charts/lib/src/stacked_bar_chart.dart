import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

typedef BarTooltipItem GetTooltipItem(
    BuildContext context, int index, BarChartRodData rod);

typedef bool CheckToShowTitle(double value);

class StackedBarChart extends StatelessWidget {
  const StackedBarChart({
    Key? key,
    required this.data,
    required this.getTooltipItem,
    required this.getBottomTitle,
    // this.checkToShowBottomTitle,
    this.horizontalInterval = 1.0,
    // this.checkToShowHorizontalLine,
  }) : super(key: key);

  /// The data points in `fl_chart` style.
  final List<BarChartGroupData> data;

  /// The tooltip callback.
  final GetTooltipItem getTooltipItem;

  /// The bottom title callback.
  final GetTitleFunction getBottomTitle;

  /// The interval for the left legend and horizontal lines.
  final double horizontalInterval;

  @override
  Widget build(BuildContext context) {
    return BarChart(BarChartData(
      alignment: BarChartAlignment.spaceBetween,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          tooltipBgColor: Theme.of(context).cardColor,
          getTooltipItem: (
            BarChartGroupData data,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) =>
              getTooltipItem(context, groupIndex, rod),
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          rotateAngle: -45.0,
          getTextStyles: (value) => Theme.of(context).textTheme.caption!,
          getTitles: getBottomTitle,
          reservedSize: 30.0,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          interval: horizontalInterval,
          getTextStyles: (value) => Theme.of(context).textTheme.caption!,
        ),
      ),
      gridData: FlGridData(
        show: true,
        horizontalInterval: horizontalInterval,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Theme.of(context).dividerColor,
          strokeWidth: 1.0,
        ),
      ),
      borderData: FlBorderData(
          show: false,
          border: Border.all(color: Theme.of(context).dividerColor)),
      barGroups: data,
      // barGroups: getData(),
    ));
  }
}

final Color dark = const Color(0xff3b8c75);
final Color normal = const Color(0xff64caad);
final Color light = const Color(0xff73e8c9);

List<BarChartGroupData> getData() {
  return [
    BarChartGroupData(
      x: 0,
      barsSpace: 4,
      barRods: [
        BarChartRodData(
            y: 17000000000,
            rodStackItems: [
              BarChartRodStackItem(0, 2000000000, dark),
              BarChartRodStackItem(2000000000, 12000000000, normal),
              BarChartRodStackItem(12000000000, 17000000000, light),
            ],
            borderRadius: const BorderRadius.all(Radius.zero)),
        BarChartRodData(
            y: 24000000000,
            rodStackItems: [
              BarChartRodStackItem(0, 13000000000, dark),
              BarChartRodStackItem(13000000000, 14000000000, normal),
              BarChartRodStackItem(14000000000, 24000000000, light),
            ],
            borderRadius: const BorderRadius.all(Radius.zero)),
        BarChartRodData(
            y: 23000000000.5,
            rodStackItems: [
              BarChartRodStackItem(0, 6000000000.5, dark),
              BarChartRodStackItem(6000000000.5, 18000000000, normal),
              BarChartRodStackItem(18000000000, 23000000000.5, light),
            ],
            borderRadius: const BorderRadius.all(Radius.zero)),
        BarChartRodData(
            y: 29000000000,
            rodStackItems: [
              BarChartRodStackItem(0, 9000000000, dark),
              BarChartRodStackItem(9000000000, 15000000000, normal),
              BarChartRodStackItem(15000000000, 29000000000, light),
            ],
            borderRadius: const BorderRadius.all(Radius.zero)),
        BarChartRodData(
            y: 32000000000,
            rodStackItems: [
              BarChartRodStackItem(0, 2000000000.5, dark),
              BarChartRodStackItem(2000000000.5, 17000000000.5, normal),
              BarChartRodStackItem(17000000000.5, 32000000000, light),
            ],
            borderRadius: const BorderRadius.all(Radius.zero)),
      ],
    ),
    BarChartGroupData(
      x: 1,
      barsSpace: 4,
      barRods: [
        BarChartRodData(
            y: 31000000000,
            rodStackItems: [
              BarChartRodStackItem(0, 11000000000, dark),
              BarChartRodStackItem(11000000000, 18000000000, normal),
              BarChartRodStackItem(18000000000, 31000000000, light),
            ],
            borderRadius: const BorderRadius.all(Radius.zero)),
        BarChartRodData(
            y: 35000000000,
            rodStackItems: [
              BarChartRodStackItem(0, 14000000000, dark),
              BarChartRodStackItem(14000000000, 27000000000, normal),
              BarChartRodStackItem(27000000000, 35000000000, light),
            ],
            borderRadius: const BorderRadius.all(Radius.zero)),
        BarChartRodData(
            y: 31000000000,
            rodStackItems: [
              BarChartRodStackItem(0, 8000000000, dark),
              BarChartRodStackItem(8000000000, 24000000000, normal),
              BarChartRodStackItem(24000000000, 31000000000, light),
            ],
            borderRadius: const BorderRadius.all(Radius.zero)),
        BarChartRodData(
            y: 15000000000,
            rodStackItems: [
              BarChartRodStackItem(0, 6000000000.5, dark),
              BarChartRodStackItem(6000000000.5, 12000000000.5, normal),
              BarChartRodStackItem(12000000000.5, 15000000000, light),
            ],
            borderRadius: const BorderRadius.all(Radius.zero)),
        BarChartRodData(
            y: 17000000000,
            rodStackItems: [
              BarChartRodStackItem(0, 9000000000, dark),
              BarChartRodStackItem(9000000000, 15000000000, normal),
              BarChartRodStackItem(15000000000, 17000000000, light),
            ],
            borderRadius: const BorderRadius.all(Radius.zero)),
      ],
    ),
    BarChartGroupData(
      x: 2,
      barsSpace: 4,
      barRods: [
        BarChartRodData(
            y: 34000000000,
            rodStackItems: [
              BarChartRodStackItem(0, 6000000000, dark),
              BarChartRodStackItem(6000000000, 23000000000, normal),
              BarChartRodStackItem(23000000000, 34000000000, light),
            ],
            borderRadius: const BorderRadius.all(Radius.zero)),
        BarChartRodData(
            y: 32000000000,
            rodStackItems: [
              BarChartRodStackItem(0, 7000000000, dark),
              BarChartRodStackItem(7000000000, 24000000000, normal),
              BarChartRodStackItem(24000000000, 32000000000, light),
            ],
            borderRadius: const BorderRadius.all(Radius.zero)),
        BarChartRodData(
            y: 14000000000.5,
            rodStackItems: [
              BarChartRodStackItem(0, 1000000000.5, dark),
              BarChartRodStackItem(1000000000.5, 12000000000, normal),
              BarChartRodStackItem(12000000000, 14000000000.5, light),
            ],
            borderRadius: const BorderRadius.all(Radius.zero)),
        BarChartRodData(
            y: 20000000000,
            rodStackItems: [
              BarChartRodStackItem(0, 4000000000, dark),
              BarChartRodStackItem(4000000000, 15000000000, normal),
              BarChartRodStackItem(15000000000, 20000000000, light),
            ],
            borderRadius: const BorderRadius.all(Radius.zero)),
        BarChartRodData(
            y: 24000000000,
            rodStackItems: [
              BarChartRodStackItem(0, 4000000000, dark),
              BarChartRodStackItem(4000000000, 15000000000, normal),
              BarChartRodStackItem(15000000000, 24000000000, light),
            ],
            borderRadius: const BorderRadius.all(Radius.zero)),
      ],
    ),
    BarChartGroupData(
      x: 3,
      barsSpace: 4,
      barRods: [
        BarChartRodData(
            y: 14000000000,
            rodStackItems: [
              BarChartRodStackItem(0, 1000000000.5, dark),
              BarChartRodStackItem(1000000000.5, 12000000000, normal),
              BarChartRodStackItem(12000000000, 14000000000, light),
            ],
            borderRadius: const BorderRadius.all(Radius.zero)),
        BarChartRodData(
            y: 27000000000,
            rodStackItems: [
              BarChartRodStackItem(0, 7000000000, dark),
              BarChartRodStackItem(7000000000, 25000000000, normal),
              BarChartRodStackItem(25000000000, 27000000000, light),
            ],
            borderRadius: const BorderRadius.all(Radius.zero)),
        BarChartRodData(
            y: 29000000000,
            rodStackItems: [
              BarChartRodStackItem(0, 6000000000, dark),
              BarChartRodStackItem(6000000000, 23000000000, normal),
              BarChartRodStackItem(23000000000, 29000000000, light),
            ],
            borderRadius: const BorderRadius.all(Radius.zero)),
        BarChartRodData(
            y: 16000000000.5,
            rodStackItems: [
              BarChartRodStackItem(0, 9000000000, dark),
              BarChartRodStackItem(9000000000, 15000000000, normal),
              BarChartRodStackItem(15000000000, 16000000000.5, light),
            ],
            borderRadius: const BorderRadius.all(Radius.zero)),
        BarChartRodData(
            y: 15000000000,
            rodStackItems: [
              BarChartRodStackItem(0, 7000000000, dark),
              BarChartRodStackItem(7000000000, 12000000000.5, normal),
              BarChartRodStackItem(12000000000.5, 15000000000, light),
            ],
            borderRadius: const BorderRadius.all(Radius.zero)),
      ],
    ),
  ];
}
