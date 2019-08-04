import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/api/client_names.dart';
import 'package:flutterhole/bloc/api/clients_over_time.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/client_names.dart';
import 'package:flutterhole/model/api/clients_over_time.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/widget/home/chart/clients_over_time_line_chart_builder.dart';

class ClientsOverTimeChartBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ClientNamesBloc clientNamesBloc =
    BlocProvider.of<ClientNamesBloc>(context);
    final ClientsOverTimeBloc clientsOverTimeBloc =
    BlocProvider.of<ClientsOverTimeBloc>(context);

    return BlocBuilder(
      bloc: clientNamesBloc,
      builder: (context, namesState) {
        if (namesState is BlocStateError<ClientNames>) {
          return buildError(namesState);
        }

        return BlocBuilder(
          bloc: clientsOverTimeBloc,
          builder: (context, overTimeState) {
            if (overTimeState is BlocStateError<ClientsOverTime>) {
              return buildError(overTimeState);
            }

            if (clientsOverTimeBloc.hasCache && clientNamesBloc.hasCache) {
              return buildSuccess(
                  clientsOverTimeBloc.cache, clientNamesBloc.cache);
            }

            return buildLoading();
          },
        );
      },
    );
  }

  Widget buildSuccess(ClientsOverTime clientsOverTime,
      ClientNames clientNames) {
    Map<String, List<FlSpot>> spots = {};

    int x = 0;
    int maxY = 0;

    clientsOverTime.overTime.forEach((String timeString, List<int> hits) {
      hits.asMap().forEach((int clientIndex, int hitsForClient) {
        if (hitsForClient > maxY) maxY = hitsForClient;

        Client currentClient;

        try {
          currentClient = clientNames.clients[clientIndex];
        } catch (e) {
          Globals.tree.log(
              'ClientChartBuilder', 'cannot find client at index $clientIndex}',
              tag: 'warning');
          currentClient = Client(name: '', ip: 'Unknown');
        }

        final String spotKey =
        currentClient.name.isEmpty ? currentClient.ip : currentClient.name;

        if (!spots.containsKey(spotKey)) {
          spots[spotKey] = [];
        }

        spots[spotKey].add(FlSpot(
            x.toDouble() * (2400 / clientsOverTime.overTime.length),
            hitsForClient.toDouble()));
      });
      x++;
    });

    spots.keys.forEach((String key) =>
    spots[key]
      ..removeLast());

    return ClientsOverTimeLineChartBuilder(spots: spots, maxY: maxY.toDouble());
  }

  StatelessWidget buildError(BlocStateError state) {
    return ListTile(
      leading: Icon(Icons.warning),
      title: Text('Cannot load domains over time: ${state.e.message}'),
    );
  }

  Center buildLoading() => Center(child: CircularProgressIndicator());
}
