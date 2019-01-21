import 'package:flutter/material.dart';
import 'package:flutter_hole/models/api.dart';
import 'package:flutter_hole/models/dashboard/info_tile.dart';

class SummaryTiles extends StatelessWidget {
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
        }

        return CircularProgressIndicator();
      }),
    );
  }
}
