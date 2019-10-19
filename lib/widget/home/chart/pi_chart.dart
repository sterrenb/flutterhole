import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/widget/home/chart/indicator.dart';

class PiChart extends StatefulWidget {
  final String title;
  final List<PieChartSectionData> sections;
  final List<Indicator> indicators;
  final double centerSpaceRadius;

  const PiChart({Key key,
    @required this.title,
    @required this.sections,
    @required this.indicators,
    this.centerSpaceRadius = 0.0})
      : super(key: key);

  @override
  _PiChartState createState() => _PiChartState();
}

class _PiChartState extends State<PiChart> {
  List<PieChartSectionData> pieChartRawSections;
  List<PieChartSectionData> showingSections;

  StreamController<PieTouchResponse> pieTouchedResultStreamController;

  int touchedIndex;

  @override
  void initState() {
    super.initState();

    pieChartRawSections = widget.sections;

    showingSections = pieChartRawSections;

    pieTouchedResultStreamController = StreamController();
    pieTouchedResultStreamController.stream
        .distinct()
        .listen((PieTouchResponse details) {
      if (details == null) {
        return;
      }

      touchedIndex = -1;
      if (details.touchedSectionPosition != null) {
        touchedIndex = showingSections.indexOf(details.touchedSection);
      }

      setState(() {
        if (details.touchInput is FlLongPressEnd) {
          touchedIndex = -1;
          showingSections = List.of(pieChartRawSections);
        } else {
          showingSections = List.of(pieChartRawSections);

          if (touchedIndex != -1) {
            final TextStyle style = showingSections[touchedIndex].titleStyle;
            showingSections[touchedIndex] =
                showingSections[touchedIndex].copyWith(
                  titleStyle: style.copyWith(
                    fontSize: 24,
                  ),
                  radius: 60,
                );
          }
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    pieTouchedResultStreamController.close();
  }

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(widget.title,
                          style: Theme
                              .of(context)
                              .textTheme
                              .title),
                      Divider(),
                    ],
                  )),
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
                          pieTouchData: PieTouchData(
                              touchResponseStreamSink:
                              pieTouchedResultStreamController.sink),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          sectionsSpace: 2.0,
                          centerSpaceRadius: widget.centerSpaceRadius,
                          sections: showingSections),
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
                children: widget.indicators,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
