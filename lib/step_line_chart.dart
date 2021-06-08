import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

typedef String StepTitleBuilder(int index);
typedef String LegendTitleBuilder(int index);

class StepLineChartEntry {
  const StepLineChartEntry(
    this.data,
    this.color,
  );

  final List<double> data;
  final Color color;
}

class StepLineChart extends HookWidget {
  static const int kInterval = 20;
  static const double kIntervalVertical = 10.0;

  const StepLineChart({
    required this.entries,
    required this.stepTitleBuilder,
    required this.legendTitleBuilder,
    Key? key,
  }) : super(key: key);

  final List<StepLineChartEntry> entries;
  final StepTitleBuilder stepTitleBuilder;
  final LegendTitleBuilder legendTitleBuilder;

  Color _backgroundColor(color) =>
      Color.alphaBlend(color.withOpacity(.5), Colors.black.withOpacity(.5));

  @override
  Widget build(BuildContext context) {
    final highestSpot = entries.first.data.reduce(math.max);
    final line = FlLine(
      color: Theme.of(context).dividerColor,
      strokeWidth: 0.5,
    );
    return LineChart(
      LineChartData(
        maxY: (highestSpot + highestSpot % kInterval).toDouble() + kInterval,
        lineBarsData: entries
            .map((entry) => LineChartBarData(
                  colors: [entry.color],
                  spots: entry.data
                      .asMap()
                      .entries
                      .map((spot) => FlSpot(spot.key.toDouble(), spot.value))
                      .toList(),
                  dotData: FlDotData(show: false),
                  barWidth: 1.0,
                  belowBarData: BarAreaData(show: true, colors: [
                    // entry.color.withOpacity(.5),
                    _backgroundColor(entry.color)
                  ]),
                  isStepLineChart: true,
                ))
            .toList(),
        gridData: FlGridData(
          show: true,
          horizontalInterval: kInterval.toDouble(),
          getDrawingHorizontalLine: (value) => line,
          // drawHorizontalLine: false,
          drawVerticalLine: true,
          verticalInterval: kIntervalVertical.toDouble(),
          checkToShowVerticalLine: (double value) {
            return value % 30 == 0;
          },
          getDrawingVerticalLine: (value) => line,
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Theme.of(context).colorScheme.onBackground,
            tooltipPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            fitInsideHorizontally: true,
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              // final textStyle = Theme.of(context).textTheme.bodyText2!.copyWith(
              //     fontSize: 12.0,
              //     color: Theme.of(context).colorScheme.background);
              final textStyle = TextStyle(
                fontSize: 12.0,
                color: Theme.of(context).colorScheme.background,
              );
              return [
                LineTooltipItem(
                  '',
                  textStyle,
                  // textAlign: TextAlign.start,
                  children: [
                    TextSpan(
                      text: legendTitleBuilder(touchedSpots.first.x.toInt()),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: '\nPermitted: '),
                    TextSpan(
                      text: (touchedSpots.first.y - touchedSpots.last.y)
                          .toInt()
                          .toString(),
                      style: TextStyle(
                        color: touchedSpots.first.bar.colors.first,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
                LineTooltipItem(
                  'Blocked: ',
                  textStyle,
                  textAlign: TextAlign.start,
                  children: [
                    TextSpan(
                      text: touchedSpots.last.y.toInt().toString(),
                      style: TextStyle(
                        color: touchedSpots.last.bar.colors.first,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                        text:
                            ' (${touchedSpots.first.y == 0 ? 0 : ((touchedSpots.last.y / touchedSpots.first.y) * 100).toStringAsFixed(1)}%)')
                  ],
                ),
              ];
            },
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor,
            ),
            left: BorderSide(
              color: Theme.of(context).dividerColor,
            ),
            right: BorderSide(
              color: Theme.of(context).dividerColor,
            ),
            bottom: BorderSide(
              color: _backgroundColor(entries.last.color),
              width: 2.0,
            ),
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          leftTitles: SideTitles(
            showTitles: true,
            getTitles: (value) => value.toStringAsFixed(0),
            getTextStyles: (_) => Theme.of(context).textTheme.caption!,
            checkToShowTitle: (double minValue, double maxValue,
                SideTitles sideTitles, double appliedInterval, double value) {
              return value % kInterval == 0 && value > 0;
            },
          ),
          bottomTitles: SideTitles(
            showTitles: true,
            // interval: 30,
            // (queries.domainsOverTime.length / 2).roundToDouble(),
            checkToShowTitle: (double minValue, double maxValue,
                SideTitles sideTitles, double appliedInterval, double value) {
              return value % 30 == 0 || value == maxValue;
            },
            getTitles: (value) => stepTitleBuilder(value.toInt()),
            getTextStyles: (_) => Theme.of(context).textTheme.caption!,
          ),
        ),
      ),
    );
  }
}
