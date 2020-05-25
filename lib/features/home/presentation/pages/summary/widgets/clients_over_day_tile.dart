import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/home/presentation/pages/summary/widgets/clients_over_day_line_chart.dart';
import 'package:flutterhole/features/home/presentation/pages/summary/widgets/line_chart_scaffold.dart';
import 'package:flutterhole/features/pihole_api/data/models/over_time_data_clients.dart';
import 'package:flutterhole/widgets/layout/indicators/failure_indicators.dart';

class ClientsOverDayTile extends StatelessWidget {
  const ClientsOverDayTile(
    this.clientsOverTimeResult, {
    Key key,
  }) : super(key: key);

  final Either<Failure, OverTimeDataClients> clientsOverTimeResult;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: LineChartScaffold(
        title: 'Client activity over last 24 hours',
        lineChart: clientsOverTimeResult.fold<Widget>(
          (failure) => CenteredFailureIndicator(failure),
          (overTimeData) {
            return SafeArea(
                minimum: EdgeInsets.only(right: 20.0),
                child: ClientsOverDayLineChart(overTimeData));
          },
        ),
      ),
    );
  }
}
