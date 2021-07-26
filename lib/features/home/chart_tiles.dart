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

final expandedProvider =
    StateProvider.family<bool, String>((ref, title) => false);

class ExpandShrinkButton extends HookWidget {
  const ExpandShrinkButton({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final expanded = useProvider(expandedProvider(title));

    return IconButton(
      tooltip: expanded.state ? 'Shrink' : 'Expand',
      onPressed: () {
        expanded.state = !expanded.state;
      },
      icon: Icon(expanded.state ? KIcons.shrink : KIcons.expand),
    );
  }
}

class ClientActivityTile extends HookWidget {
  const ClientActivityTile({Key? key}) : super(key: key);

  static const title = 'Client activity';

  @override
  Widget build(BuildContext context) {
    final clientActivityValue = useProvider(activeClientActivityProvider);
    final expanded = useProvider(expandedProvider(title));

    return GridCard(
      child: Column(
        children: [
          const ListTile(
            title: Text('Client activity'),
            leading: GridIcon(KIcons.clientActivity),
            trailing: ExpandShrinkButton(title: title),
          ),
          AnimatedContainer(
            duration: kThemeAnimationDuration,
            curve: Curves.ease,
            height: expanded.state ? kMinTileHeight * 2 : kMinTileHeight,
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

  static const title = 'Queries over time';

  @override
  Widget build(BuildContext context) {
    final queriesOverTimeValue = useProvider(activeQueriesOverTimeProvider);
    final expanded = useProvider(expandedProvider(title));

    return GridCard(
        child: Column(
      children: [
        const ListTile(
          title: Text(title),
          leading: GridIcon(KIcons.queriesOverTime),
          trailing: ExpandShrinkButton(title: title),
        ),
        AnimatedContainer(
          duration: kThemeAnimationDuration,
          curve: Curves.ease,
          height: expanded.state ? kMinTileHeight * 2 : kMinTileHeight,
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
