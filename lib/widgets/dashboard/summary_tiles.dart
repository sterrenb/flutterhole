import 'package:flutter/material.dart';
import 'package:sterrenburg.github.flutterhole/api/summary_model.dart';
import 'package:sterrenburg.github.flutterhole/widgets/app_state.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/friendly_exception.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/info_tile.dart';

/// A widget that shows a [List] of [InfoTile]s with statistics of the Pi-hole.
class SummaryTiles extends StatefulWidget {
  @override
  _SummaryTilesState createState() {
    return new _SummaryTilesState();
  }
}

class _SummaryTilesState extends State<SummaryTiles> {
  static String _numberWithCommas(String string) {
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final Function matchFunc = (Match match) => '${match[1]},';
    return string.replaceAllMapped(reg, matchFunc);
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.of(context);
    return FutureBuilder<SummaryModel>(
      future: appState.provider.fetchSummary(),
      builder: ((BuildContext context, AsyncSnapshot<SummaryModel> snapshot) {
        if (snapshot.hasData) {
          final List<Widget> infoTiles = [
            InfoTile(
              title: ' Total Queries',
              value: _numberWithCommas(snapshot.data.totalQueries.toString()),
            ),
            InfoTile(
              title: ' Queries Blocked',
              value: _numberWithCommas(snapshot.data.queriesBlocked.toString()),
            ),
            InfoTile(
              title: ' Percent Blocked',
              value: snapshot.data.percentBlocked.toString() + '%',
            ),
            InfoTile(
              title: ' Domains on Blocklist',
              value: _numberWithCommas(
                  snapshot.data.domainsOnBlocklist.toString()),
            ),
          ];

          return Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: infoTiles,
          );
        } else if (snapshot.hasError) {
          return FriendlyException(message: snapshot.error.toString());
        }

        return Center(child: CircularProgressIndicator());
      }),
    );
  }
}
