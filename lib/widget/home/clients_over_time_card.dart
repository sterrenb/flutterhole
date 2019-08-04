import 'package:flutter/material.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/service/routes.dart';
import 'package:flutterhole/widget/home/chart/clients_over_time_chart_builder.dart';

class ClientsOverTimeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                    style: Theme.of(context).textTheme.title,
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
        AspectRatio(aspectRatio: 2, child: ClientsOverTimeChartBuilder()),
      ],
    ));
  }
}
