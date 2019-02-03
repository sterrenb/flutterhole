import 'package:flutter/material.dart';
import 'package:flutter_hole/models/api.dart';
import 'package:flutter_hole/models/dashboard/info_tile.dart';
import 'package:flutter_hole/screens/settings_screen.dart';

/// A widget that shows a [List] of [InfoTile]s with statistics of the Pi-hole.
class SummaryTiles extends StatefulWidget {
  @override
  _SummaryTilesState createState() {
    return new _SummaryTilesState();
  }
}

class _SummaryTilesState extends State<SummaryTiles> {
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

          return Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: infoTiles,
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32.0, vertical: 8.0),
                  child: Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    child: Text('View settings'),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingsScreen()));
                    },
                  ),
                ),
              ],
            ),
          );
        }

        return Center(child: CircularProgressIndicator());
      }),
    );
  }
}
