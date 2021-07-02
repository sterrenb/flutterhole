import 'package:charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:pihole_api/pihole_api.dart';

class PiQueriesDoughnutChart extends StatelessWidget {
  const PiQueriesDoughnutChart(
    this.title,
    this.queryTypes, {
    Key? key,
  }) : super(key: key);

  final String title;
  final PiQueryTypes queryTypes;

  static const List<Color> colors = [
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.red,
    Colors.yellow,
    Colors.purple,
  ];

  @override
  Widget build(BuildContext context) {
    return DoughnutChart(
      title: title,
      dataSource: (PiQueryTypes queryTypes) {
        int index = 0;
        return queryTypes.types.entries
            .map((e) => DoughnutChartData(
                e.key, e.value, colors.elementAt(index++ % colors.length)))
            .toList();
      }(queryTypes),
    );
  }
}

class ForwardDestinationsDoughnutChart extends StatelessWidget {
  const ForwardDestinationsDoughnutChart(
    this.title,
    this.forwardDestinations, {
    Key? key,
  }) : super(key: key);

  final String title;
  final PiForwardDestinations forwardDestinations;

  static const List<Color> colors = [
    Colors.red,
    Colors.yellow,
    Colors.purple,
    Colors.blue,
    Colors.orange,
    Colors.green,
  ];

  @override
  Widget build(BuildContext context) {
    return DoughnutChart(
      title: title,
      dataSource: (PiForwardDestinations forwardDestinations) {
        int index = 0;
        return forwardDestinations.destinations.entries
            .map((e) => DoughnutChartData(
                e.key, e.value, colors.elementAt(index++ % colors.length)))
            .toList();
      }(forwardDestinations),
    );
  }
}
