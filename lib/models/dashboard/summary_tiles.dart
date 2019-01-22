import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hole/models/api.dart';
import 'package:flutter_hole/models/dashboard/info_tile.dart';

class SummaryTiles extends StatefulWidget {
  @override
  SummaryTilesState createState() {
    return new SummaryTilesState();
  }
}

class SummaryTilesState extends State<SummaryTiles> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      // TODO maybe use AppState, so that we can trigger rebuilds on new API fetches
      future: Api.fetchSummary(),
      builder: ((BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          List<Widget> infoTiles = [];
          snapshot.data.forEach((String key, String value) {
            infoTiles.add(InfoTile(
              title: key,
              value: value,
            ));
          });

          return ListView(
            children: infoTiles,
          );
        } else if (snapshot.hasError) {
          String message;
          final Object error = snapshot.error;
          if (error.runtimeType == TimeoutException) {
            message =
                'The server timed out after ${(error as TimeoutException).duration.inSeconds} seconds.';
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(message),
                IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () {
                      setState(() {});
                    }),
              ],
            ),
          );
        }

        return Center(child: CircularProgressIndicator());
      }),
    );
  }
}
