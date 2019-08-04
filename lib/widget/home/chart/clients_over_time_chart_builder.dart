import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/api/clients_over_time.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/clients_over_time.dart';
import 'package:flutterhole/widget/home/chart/line_chart_builder.dart';

class ClientsOverTimeChartBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ClientsOverTimeBloc clientsOverTimeBloc =
        BlocProvider.of<ClientsOverTimeBloc>(context);
    return BlocBuilder(
      bloc: clientsOverTimeBloc,
      builder: (context, state) {
        if (state is BlocStateSuccess<ClientsOverTime>) {
          final clientsOverTime = state.data;
          Map<String, List<FlSpot>> spots = {};

          int index = 0;
          int maxY = 0;
          clientsOverTime.overTime.forEach((String timeString, List<int> hits) {
            hits.asMap().forEach((int clientIndex, int hitsForClient) {
              final String key = 'key ${clientIndex.toString()}';

              if (hitsForClient > maxY) maxY = hitsForClient;

              if (index % 10 == 0) {
                print(
                    'clientIndex $clientIndex: $hitsForClient hitsForClient @client:$key');
              }
              if (!spots.containsKey(key)) {
                spots[key] = [];
              }

              spots[key].add(FlSpot(
                  index.toDouble() * (2400 / clientsOverTime.overTime.length),
                  hitsForClient.toDouble()));
            });
            index++;
          });
          return LineChartBuilder(spots: spots, maxY: maxY.toDouble());
        }
        if (state is BlocStateError<ClientsOverTime>) {
          if (state.e.message == 'API token is empty') {
            return Container();
          }

          return Card(
              child: ListTile(
            leading: Icon(Icons.warning),
            title: Text('Cannot load domains over time: ${state.e.message}'),
          ));
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
