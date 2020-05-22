import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/features/pihole_api/data/models/over_time_data_clients.dart';

class ClientsOverDayLineChart extends StatelessWidget {
  const ClientsOverDayLineChart(
    this.overTimeData, {
    Key key,
  }) : super(key: key);

  final OverTimeDataClients overTimeData;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(),
    );
  }
}
