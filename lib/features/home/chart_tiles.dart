import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/dialogs.dart';
import 'package:flutterhole_web/features/charts/client_activity_bar_chart.dart';
import 'package:flutterhole_web/features/charts/queries_over_time_bar_chart.dart';
import 'package:flutterhole_web/features/grid/grid_layout.dart';
import 'package:flutterhole_web/features/layout/code_card.dart';
import 'package:flutterhole_web/features/settings/active_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pihole_api/pihole_api.dart';

import 'dashboard_tiles.dart';

class ClientActivityTile extends HookWidget {
  const ClientActivityTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final clientActivityValue = useProvider(activeClientActivityProvider);

    return GridCard(
      child: Column(
        children: [
          const ListTile(
            title: Text('Client activity'),
            leading: GridIcon(KIcons.clientActivity),
          ),
          SizedBox(
            height: kMinTileHeight,
            child: AnimatedSwitcher(
              duration: kThemeAnimationDuration,
              child: clientActivityValue.when(
                data: (PiClientActivityOverTime activity) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ClientActivityBarChart(
                      activity,
                      key: const ValueKey('data'),
                    ),
                  );
                },
                loading: () => const Center(
                    child: CircularProgressIndicator(
                  key: ValueKey('loading'),
                )),
                error: (e, s) => InkWell(
                    key: const ValueKey('error'),
                    onTap: () {
                      showErrorDialog(context, e, s);
                    },
                    child: const Center(
                        child: Text('Fetching client activity failed.'))),
              ),
            ),
          ),
        ],
      ),
      // child: StackedBarChart.withSampleData(),
    );
  }
}

class QueriesOverTimeTile extends HookWidget {
  const QueriesOverTimeTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final queriesOverTimeValue = useProvider(activeQueriesOverTimeProvider);

    return GridCard(
        child: Column(
      children: [
        const ListTile(
          title: Text('Queries over time'),
          leading: GridIcon(KIcons.queriesOverTime),
        ),
        SizedBox(
          height: kMinTileHeight,
          child: AnimatedSwitcher(
            duration: kThemeAnimationDuration,
            child: queriesOverTimeValue.when(
              data: (queriesOverTime) => QueriesOverTimeBarChart(
                queriesOverTime,
                key: const ValueKey('data'),
              ),
              loading: () => const Center(
                  child: CircularProgressIndicator.adaptive(
                      key: ValueKey('loading'))),
              error: (e, s) => GridInkWell(
                  key: const ValueKey('error'),
                  onTap: () {
                    showErrorDialog(context, e, s);
                  },
                  child: Center(child: CodeCard(code: e.toString()))),
            ),
          ),
        ),
      ],
    ));
  }
}
