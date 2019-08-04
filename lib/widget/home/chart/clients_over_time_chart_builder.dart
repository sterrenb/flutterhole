import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/api/client_names.dart';
import 'package:flutterhole/bloc/api/clients_over_time.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/client_names.dart';
import 'package:flutterhole/model/api/clients_over_time.dart';
import 'package:flutterhole/widget/home/chart/line_chart_builder.dart';

class ClientsOverTimeChartBuilder extends StatefulWidget {
  @override
  _ClientsOverTimeChartBuilderState createState() =>
      _ClientsOverTimeChartBuilderState();
}

class _ClientsOverTimeChartBuilderState
    extends State<ClientsOverTimeChartBuilder> {
  ClientNames clientNamesCache;

  @override
  void initState() {
    super.initState();
    clientNamesCache = ClientNames([]);
  }

  @override
  Widget build(BuildContext context) {
    final ClientNamesBloc clientNamesBloc =
    BlocProvider.of<ClientNamesBloc>(context);
    final ClientsOverTimeBloc clientsOverTimeBloc =
    BlocProvider.of<ClientsOverTimeBloc>(context);
    return BlocBuilder(
      bloc: clientNamesBloc,
      builder: (context, state) {
        if (state is BlocStateSuccess<ClientNames>) {
          clientNamesCache = state.data;
        }
        return BlocBuilder(
          bloc: clientsOverTimeBloc,
          builder: (context, state) {
            if (state is BlocStateSuccess<ClientsOverTime>) {
              return buildSuccess(state);
            }
            if (state is BlocStateError<ClientsOverTime>) {
              return buildError(state);
            }
            return buildLoading();
          },
        );
      },
    );
  }

  LineChartBuilder buildSuccess(BlocStateSuccess<ClientsOverTime> state) {
    final clientsOverTime = state.data;
    Map<String, List<FlSpot>> spots = {};

    int index = 0;
    int maxY = 0;
    clientsOverTime.overTime.forEach((String timeString, List<int> hits) {
      hits.asMap().forEach((int clientIndex, int hitsForClient) {
        if (hitsForClient > maxY) maxY = hitsForClient;

        final Client currentClient = clientNamesCache.clients[clientIndex];

        final String spotKey =
        currentClient.name.isEmpty ? currentClient.ip : currentClient.name;


//        final String spotKey = '$clientIdentifier: $hitsForClient';
//        final spotKey = '$clientIndex:${currentClient.name}';

        print('client 0: ${clientNamesCache.clients.first}');
        print('client 1: ${clientNamesCache.clients[1]}');

        if (!spots.containsKey(spotKey)) {
          spots[spotKey] = [];
        }

        spots[spotKey].add(FlSpot(
            index.toDouble() * (2400 / clientsOverTime.overTime.length),
            hitsForClient.toDouble()));
      });
      index++;
    });

    return LineChartBuilder(spots: spots, maxY: maxY.toDouble());
  }

  StatelessWidget buildError(BlocStateError<ClientsOverTime> state) {
    if (state.e.message == 'API token is empty') {
      return Container();
    }

    return Card(
        child: ListTile(
          leading: Icon(Icons.warning),
          title: Text('Cannot load domains over time: ${state.e.message}'),
        ));
  }

  Center buildLoading() => Center(child: CircularProgressIndicator());
}
