import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/features/api/data/models/forward_destinations.dart';
import 'package:flutterhole/features/home/presentation/pages/summary/notifiers/pie_chart_notifier.dart';
import 'package:provider/provider.dart';
import 'package:supercharged/supercharged.dart';

const double kShowTitleThresholdPercentage = 5.0;

const List<Color> _chartColors = [
  Colors.orange,
  Colors.green,
  Colors.red,
  Colors.blue,
  Colors.yellow,
  Colors.purple,
];

class ForwardDestinationsPieChart extends StatelessWidget {
  const ForwardDestinationsPieChart(
    this.forwardDestinations, {
    Key key,
  }) : super(key: key);

  final Map<ForwardDestination, double> forwardDestinations;

  static Color colorAtIndex(int index) =>
      _chartColors.elementAtOrNull(index % _chartColors.length);

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
          sections: forwardDestinations
              .map((forwardDestination, percentage) {
                final int index = forwardDestinations.keys
                    .toList()
                    .indexOf(forwardDestination);

                return MapEntry(
                    index,
                    PieChartSectionData(
                      value: percentage,
                      title: '${percentage.toStringAsFixed(0)}%',
                      showTitle: percentage >= kShowTitleThresholdPercentage,
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
