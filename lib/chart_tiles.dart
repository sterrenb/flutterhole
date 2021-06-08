import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/doughnut_chart.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/features/home/dashboard_tiles.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:flutterhole_web/step_line_chart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class QueryTypesTile extends HookWidget {
  static const String title = 'Query Types';

  static const List<Color> _chartColors = [
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.red,
    Colors.yellow,
    Colors.purple,
  ];

  @override
  Widget build(BuildContext context) {
    final pi = useProvider(activePiProvider).state;
    final queryTypes = useProvider(queryTypesProvider(pi));
    final selected = useProvider(doughnutChartProvider(title));

    return Card(
      child: Center(
        child: queryTypes.when(
          data: (types) {
            return ChartTileScaffold(
                left: LegendTileList(
                  title: title,
                  legendTiles: (PiQueryTypes queryTypes) {
                    int index = 0;

                    return queryTypes.types.entries.map((queryTypeEntry) {
                      return Tooltip(
                        message:
                            '${queryTypeEntry.key}: ${queryTypeEntry.value.toStringAsFixed(2)}%',
                        child: LegendTile(
                          title: queryTypeEntry.key,
                          trailing:
                              '${queryTypeEntry.value.toStringAsFixed(0)}%',
                          selected: selected.state == queryTypeEntry.key,
                          color: _chartColors
                              .elementAt(index++ % _chartColors.length),
                        ),
                      );
                    }).toList();
                  }(types),
                ),
                right: DoughnutChart(
                  title: title,
                  dataSource: (PiQueryTypes queryTypes) {
                    queryTypes.types.removeWhere((key, value) => value <= 0);
                    int index = 0;
                    return queryTypes.types.entries
                        .map((e) => DoughnutChartData(
                            e.key,
                            e.value,
                            _chartColors
                                .elementAt(index++ % _chartColors.length)))
                        .toList();
                  }(types),
                ));
          },
          loading: () => CircularProgressIndicator(),
          error: (e, s) => Text('${e.toString()}'),
        ),
      ),
    );
  }
}

class ForwardDestinationsTile extends HookWidget {
  static const String title = 'Queries answered by';

  static const List<Color> _chartColors = [
    Colors.red,
    Colors.yellow,
    Colors.purple,
    Colors.blue,
    Colors.orange,
    Colors.green,
  ];

  @override
  Widget build(BuildContext context) {
    final pi = useProvider(activePiProvider).state;
    final forwardDestinations = useProvider(forwardDestinationsProvider(pi));
    final selected = useProvider(doughnutChartProvider(title));

    return Card(
      child: Center(
        child: forwardDestinations.when(
          data: (PiForwardDestinations destinations) {
            return ChartTileScaffold(
              left: LegendTileList(
                title: title,
                legendTiles: (PiForwardDestinations destinations) {
                  int index = 0;

                  return destinations.destinations.entries.map((destination) {
                    final domain = destination.key.split('|').first;
                    return Tooltip(
                      message:
                          '$domain: ${destination.value.toStringAsFixed(2)}%',
                      child: LegendTile(
                        title: domain,
                        trailing: '${destination.value.toStringAsFixed(0)}%',
                        selected: selected.state == destination.key,
                        color: _chartColors
                            .elementAt(index++ % _chartColors.length),
                      ),
                    );
                  }).toList();
                }(destinations),
              ),
              right: DoughnutChart(
                title: title,
                dataSource: (PiForwardDestinations forwardDestinations) {
                  forwardDestinations.destinations
                      .removeWhere((key, value) => value <= 0);
                  int index = 0;
                  return forwardDestinations.destinations.entries
                      .map((e) => DoughnutChartData(
                          e.key,
                          e.value,
                          _chartColors
                              .elementAt(index++ % _chartColors.length)))
                      .toList();
                }(destinations),
              ),
            );
          },
          loading: () => CircularProgressIndicator(),
          error: (e, s) => Text('${e.toString()}'),
        ),
      ),
    );
  }
}

final format = DateFormat.Hm();

class QueriesBarChartTile extends HookWidget {
  const QueriesBarChartTile({Key? key}) : super(key: key);

  static const tile = StaggeredTile.fit(4);
  static const title = 'Queries over time';

  @override
  Widget build(BuildContext context) {
    final pi = useProvider(activePiProvider).state;
    final queriesOverTime = useProvider(queriesOverTimeProvider(pi));
    final expanded = useProvider(expandableDashboardTileProvider(title));

    final when = queriesOverTime.when(
      data: (PiQueriesOverTime queries) {
        return Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 24.0),
          child: StepLineChart(
              entries: [
                StepLineChartEntry(
                    queries.domainsOverTime.values
                        .map((e) => e.toDouble())
                        .toList(),
                    KColors.success),
                StepLineChartEntry(
                    queries.adsOverTime.values
                        .map((e) => e.toDouble())
                        .toList(),
                    KColors.error),
              ],
              stepTitleBuilder: (index) {
                final m = queries.domainsOverTime.keys.elementAt(index);
                return DateFormat.Hm().format(m.subtract(Duration(minutes: 5)));
              },
              legendTitleBuilder: (index) {
                final m = queries.domainsOverTime.keys.elementAt(index);
                final before =
                    DateFormat.Hm().format(m.subtract(Duration(minutes: 5)));
                final after =
                    DateFormat.Hm().format(m.add(Duration(minutes: 5)));
                return '$before - $after';
              }),
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (e, s) => Text('${e.toString()}'),
    );
    return Card(
      child: ExpandableDashboardTile(
        title,
        leading: DashboardTileIcon(KIcons.queriesOverTime),
        title: TileTitle(title),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: kMinTileHeight),
          child: Container(
            height: expanded.state ? kMinTileHeight * 2 : kMinTileHeight,
            child: Center(child: when),
          ),
        ),
      ),
    );
  }
}

final expandableDashboardTileProvider =
    StateProvider.family<bool, String>((ref, title) => false);

class ExpandableDashboardTile extends HookWidget {
  const ExpandableDashboardTile(
    this.hookTitle, {
    Key? key,
    required this.title,
    required this.child,
    this.leading,
  }) : super(key: key);

  final Widget title;
  final Widget? leading;
  final String hookTitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final vsync = useSingleTickerProvider();
    final expanded = useProvider(expandableDashboardTileProvider(hookTitle));

    return AnimatedSize(
      vsync: vsync,
      duration: kThemeAnimationDuration * 2,
      alignment: Alignment.topCenter,
      curve: Curves.ease,
      child: Column(
        children: [
          ListTile(
            title: title,
            leading: leading,
            trailing: IconButton(
              tooltip: expanded.state ? 'Collapse' : 'Expand',
              icon: Icon(expanded.state ? KIcons.shrink : KIcons.expand),
              onPressed: () {
                expanded.state = !expanded.state;
              },
            ),
          ),
          child,
        ],
      ),
    );
  }
}
