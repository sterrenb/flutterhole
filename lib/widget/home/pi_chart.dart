import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'indicator.dart';

class PiChart extends StatelessWidget {
  final String title;
  final List<PieChartSectionData> sections;
  final List<Indicator> indicators;
  final double centerSpaceRadius;

  const PiChart(
      {Key key,
      @required this.title,
      @required this.sections,
      @required this.indicators,
      this.centerSpaceRadius = 0.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Card(
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: SafeArea(
                  minimum: EdgeInsets.all(16.0),
                  child: Text(title, style: Theme.of(context).textTheme.title)),
            ),
            SafeArea(
              minimum: EdgeInsets.symmetric(vertical: 16.0),
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: FlChart(
                    chart: PieChart(
                      PieChartData(
                          borderData: FlBorderData(
                            show: false,
                          ),
                          sectionsSpace: 2.0,
                          centerSpaceRadius: centerSpaceRadius,
                          sections: sections),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: indicators,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
