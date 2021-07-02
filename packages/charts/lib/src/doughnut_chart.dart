import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// TODO parameterize
const double _kShowTitleThresholdPercentage = 105.0;

final doughnutChartSelectedProvider =
    StateProvider.family<String, String>((ref, title) => '');

class DoughnutChartData {
  DoughnutChartData(this.x, this.y, this.color);

  final String x;
  final double y;
  final Color color;
}

class DoughnutChart extends HookWidget {
  const DoughnutChart({
    Key? key,
    required this.title,
    required this.dataSource,
  }) : super(key: key);

  final String title;
  final List<DoughnutChartData> dataSource;

  @override
  Widget build(BuildContext context) {
    final selected = useProvider(doughnutChartSelectedProvider(title));
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 200,
          maxHeight: 200,
        ),
        child: PieChart(PieChartData(
          startDegreeOffset: 270,
          borderData: FlBorderData(show: false),
          pieTouchData:
              PieTouchData(touchCallback: (PieTouchResponse pieTouchResponse) {
            final desiredTouch =
                pieTouchResponse.touchInput is! PointerExitEvent &&
                    pieTouchResponse.touchInput is! PointerUpEvent;
            if (desiredTouch && pieTouchResponse.touchedSection != null) {
              final index =
                  pieTouchResponse.touchedSection!.touchedSectionIndex;
              if (index >= 0) {
                selected.state = dataSource.elementAt(index).x;
                return;
              }
            }
            selected.state = '';
          }),
          sectionsSpace: selected.state.isNotEmpty ? 4.0 : 2.0,
          sections: dataSource
              .map((data) => PieChartSectionData(
                    title: '${data.y.toStringAsFixed(0)}%',
                    value: data.y,
                    color: data.color,
                    showTitle: data.y >= _kShowTitleThresholdPercentage,
                    radius: selected.state == data.x ? 45 : 40,
                  ))
              .toList(),
        )),
      ),
    );
  }
}
