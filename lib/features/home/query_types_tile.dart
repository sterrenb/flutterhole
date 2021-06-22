import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/doughnut_chart.dart';
import 'package:flutterhole_web/features/grid/grid_layout.dart';
import 'package:flutterhole_web/features/home/charts.dart';
import 'package:flutterhole_web/pihole_endpoint_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class QueryTypesTileTwo extends HookWidget {
  const QueryTypesTileTwo({Key? key}) : super(key: key);

  static const String title = 'Query types';

  @override
  Widget build(BuildContext context) {
    final queryTypesValue = useProvider(activeQueryTypesProvider);
    final selected = useProvider(doughnutChartProvider(title));

    final left = queryTypesValue.when(
      data: (queryTypes) => DoughnutChartLegendList(
        title: title,
        iconData: KIcons.about,
        builder: (context, index) {
          final queryTypeEntry = queryTypes.types.entries.elementAt(index);
          return Tooltip(
            message:
                '${queryTypeEntry.key}: ${queryTypeEntry.value.toStringAsFixed(2)}%',
            child: LegendTile(
              title: queryTypeEntry.key,
              trailing: '${queryTypeEntry.value.toStringAsFixed(0)}%',
              selected: selected.state == queryTypeEntry.key,
              color: PiQueriesDoughnutChart.colors
                  .elementAt(index % PiQueriesDoughnutChart.colors.length),
            ),
          );
        },
        childCount: queryTypes.types.length,
      ),
      loading: () => CenteredGridTileLoadingIndicator(),
      error: (error, stacktrace) => CenteredGridTileErrorIndicator(error),
    );

    return DoubleGridCard(
      left: left,
      // left: Container(),
      right: queryTypesValue.when(
        data: (queryTypes) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: PiQueriesDoughnutChart(title, queryTypes),
        ),
        loading: () => CenteredGridTileLoadingIndicator(),
        error: (error, stacktrace) => CenteredGridTileErrorIndicator(error),
      ),
    );
  }
}

class ForwardDestinationsTileTwo extends HookWidget {
  static const String title = 'Forward destinations';

  const ForwardDestinationsTileTwo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final forwardDestinationsValue =
        useProvider(activeForwardDestinationsProvider);
    final selected = useProvider(doughnutChartProvider(title));

    return DoubleGridCard(
      left: forwardDestinationsValue.when(
        data: (forwardDestinations) => DoughnutChartLegendList(
          title: title,
          iconData: KIcons.about,
          builder: (context, index) {
            final destination =
                forwardDestinations.destinations.entries.elementAt(index);
            final domain = destination.key.split('|').first;
            return Tooltip(
              message: '$domain: ${destination.value.toStringAsFixed(2)}%',
              child: LegendTile(
                title: domain,
                trailing: '${destination.value.toStringAsFixed(0)}%',
                selected: selected.state == destination.key,
                color: ForwardDestinationsDoughnutChart.colors.elementAt(
                    index % ForwardDestinationsDoughnutChart.colors.length),
              ),
            );
          },
          childCount: forwardDestinations.destinations.length,
        ),
        loading: () => CenteredGridTileLoadingIndicator(),
        error: (error, stacktrace) => CenteredGridTileErrorIndicator(error),
      ),
      right: forwardDestinationsValue.when(
        data: (forwardDestinations) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: ForwardDestinationsDoughnutChart(title, forwardDestinations),
        ),
        loading: () => CenteredGridTileLoadingIndicator(),
        error: (error, stacktrace) => CenteredGridTileErrorIndicator(error),
      ),
    );
  }
}
