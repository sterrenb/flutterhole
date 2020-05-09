import 'package:flutter/material.dart';
import 'package:flutterhole/features/home/presentation/pages/summary/notifiers/pie_chart_notifier.dart';
import 'package:provider/provider.dart';

const double kShowTitleThresholdPercentage = 5.0;

class PieChartScaffold extends StatelessWidget {
  const PieChartScaffold({
    Key key,
    @required this.title,
    @required this.pieChart,
    this.legendItems = const [],
  }) : super(key: key);

  final String title;

  /// Typically a [PChart].
  final Widget pieChart;

  /// Typically a list of [GraphLegendItem]s.
  final List<Widget> legendItems;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PieChartNotifier>(
      create: (_) => PieChartNotifier(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '$title',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  ...legendItems,
                ],
              ),
            ),
            SizedBox(width: 12.0),
            Flexible(flex: 3, child: pieChart),
          ],
        ),
      ),
    );
  }
}
