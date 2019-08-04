import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/api/clients_over_time.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/clients_over_time.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/service/routes.dart';
import 'package:flutterhole/widget/home/chart/clients_over_time_chart_builder.dart';

class ClientsOverTimeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final clientsOverTimeBloc = BlocProvider.of<ClientsOverTimeBloc>(context);
    return BlocBuilder(
      bloc: clientsOverTimeBloc,
      builder: (context, state) {
        if (state is BlocStateError<ClientsOverTime>) {
          if (state.e.message == 'API token is empty') {
            return Container();
          }

          return Card(
              child: ListTile(
                leading: Icon(Icons.warning),
                title: Text(
                    'Cannot load clients over time: ${state.e.message}'),
              ));
        }

        if (clientsOverTimeBloc.hasCache) {
          return Card(
              child: Column(
                children: <Widget>[
                  SafeArea(
                    minimum: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "Clients over last 24 hours",
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .title,
                            ),
                            IconButton(
                              tooltip: 'View full screen',
                              icon: Icon(Icons.keyboard_arrow_right),
                              onPressed: () {
                                Globals.navigateTo(
                                  context,
                                  graphClientsOverTimePath,
                                );
                              },
                            )
                          ],
                        ),
                        Divider(),
                      ],
                    ),
                  ),
                  AspectRatio(
                      aspectRatio: 2, child: ClientsOverTimeChartBuilder()),
                ],
              ));
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
