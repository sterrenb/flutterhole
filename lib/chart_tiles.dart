import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/doughnut_chart.dart';
import 'package:flutterhole_web/features/entities/api_entities.dart';
import 'package:flutterhole_web/features/grid/grid_layout.dart';
import 'package:flutterhole_web/features/home/charts.dart';
import 'package:flutterhole_web/features/home/dashboard_tiles.dart';
import 'package:flutterhole_web/features/pihole/active_pi.dart';
import 'package:flutterhole_web/features/themes/theme_builders.dart';
import 'package:flutterhole_web/formatting.dart';
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
    final queryTypes = useProvider(activeQueryTypesProvider);
    final selected = useProvider(doughnutChartProvider(title));

    return Card(
      child: Center(
        child: queryTypes.when(
          data: (types) {
            return DoughnutScaffold(
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
                right: PiQueriesDoughnutChart(title, types));
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
    final forwardDestinations = useProvider(activeForwardDestinationsProvider);
    final selected = useProvider(doughnutChartProvider(title));

    return Card(
      child: Center(
        child: forwardDestinations.when(
          data: (PiForwardDestinations destinations) {
            return DoughnutScaffold(
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
          error: (e, s) => Text(e.toString()),
        ),
      ),
    );
  }
}

final format = DateFormat.Hm();

class QueriesBarChartTile extends HookWidget {
  const QueriesBarChartTile({Key? key}) : super(key: key);

  static const title = 'Queries over time';

  @override
  Widget build(BuildContext context) {
    final queriesOverTime = useProvider(activeQueriesOverTimeProvider);
    final expanded = useProvider(expandableDashboardTileProvider(title));

    return Card(
      child: ExpandableDashboardTile(
        title,
        leading: GridIcon(KIcons.queriesOverTime),
        title: TileTitle(title),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: kMinTileHeight),
          child: Container(
            height: expanded.state ? kMinTileHeight * 2 : kMinTileHeight,
            child: Center(
                child: queriesOverTime.when(
              data: (PiQueriesOverTime queries) {
                List<int> domainValues =
                    queries.domainsOverTime.values.toList();
                List<int> adValues = queries.adsOverTime.values.toList();
                List<DateTime> domainKeys =
                    queries.domainsOverTime.keys.toList();

                return Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 24.0),
                  child: PiColorsBuilder(
                    builder: (context, piColors, _) => StepLineChart(
                      entries: [
                        StepLineChartEntry(
                            domainValues.map((e) => e.toDouble()).toList(),
                            piColors.success),
                        StepLineChartEntry(
                            adValues.map((e) => e.toDouble()).toList(),
                            piColors.error),
                      ],
                      stepTitleBuilder: (index) {
                        final m = domainKeys.elementAt(index);
                        return DateFormat.Hm()
                            .format(m.subtract(Duration(minutes: 5)));
                      },
                      legendChildrenBuilder: (index, touchedSpots) {
                        final m = domainKeys.elementAt(index);
                        final textStyle = TextStyle(
                          fontSize: 12.0,
                          color: Theme.of(context).colorScheme.background,
                        );
                        return [
                          LineTooltipItem(
                            '',
                            textStyle,
                            textAlign: TextAlign.start,
                            children: [
                              TextSpan(
                                text: m.beforeAfter(const Duration(minutes: 5)),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: '\nPermitted: '),
                              TextSpan(
                                text:
                                    (touchedSpots.first.y - touchedSpots.last.y)
                                        .toInt()
                                        .toString(),
                                style: TextStyle(
                                  color: touchedSpots.first.bar.colors.first,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(text: '\nBlocked: '),
                              TextSpan(
                                text: touchedSpots.last.y.toInt().toString(),
                                style: TextStyle(
                                  color: touchedSpots.last.bar.colors.first,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                  text:
                                      ' (${touchedSpots.first.y == 0 ? 0 : ((touchedSpots.last.y / touchedSpots.first.y) * 100).toStringAsFixed(1)}%)'),
                            ],
                          ),
                          LineTooltipItem(
                            '',
                            TextStyle(fontSize: 0),
                            textAlign: TextAlign.start,
                          ),
                        ];
                      },
                    ),
                  ),
                );
              },
              loading: () => CircularProgressIndicator(),
              error: (e, s) => Text(e.toString()),
            )),
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
      duration: kThemeAnimationDuration * 1,
      alignment: Alignment.topCenter,
      curve: Curves.ease,
      child: Column(
        children: [
          ListTile(
            title: title,
            leading: leading,
            onTap: () {
              expanded.state = !expanded.state;
            },
            trailing: Icon(expanded.state ? KIcons.shrink : KIcons.expand),
            // trailing: IconButton(
            //   tooltip:
            //       expanded.state ? 'Collapse $hookTitle' : 'Expand $hookTitle',
            //   icon: Icon(expanded.state ? KIcons.shrink : KIcons.expand),
            //   onPressed: () {
            //     // expanded.state = !expanded.state;
            //   },
            // ),
          ),
          child,
        ],
      ),
    );
  }
}

class ClientActivityBarChartTile extends HookWidget {
  const ClientActivityBarChartTile({Key? key}) : super(key: key);

  static const title = 'Client activity';

  static const List<Color> _chartColors = [
    Colors.amber,
    Colors.cyan,
    Colors.blueGrey,
    Colors.yellow,
    Colors.purple,
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.red,
  ];

  @override
  Widget build(BuildContext context) {
    // final pi = useProvider(activePiProvider);
    final clientActivity = useProvider(activeClientActivityProvider);
    final expanded = useProvider(expandableDashboardTileProvider(title));

    final when = clientActivity.when(
      data: (PiClientActivityOverTime activity) {
        return Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 24.0),
          child: StepLineChart(
            entries: activity.byClient.entries
                .map((entry) => StepLineChartEntry(
                    entry.value.map((e) => e.toDouble()).toList(),
                    _chartColors.elementAt(activity.clients.indexOf(entry.key) %
                        _chartColors.length)))
                .toList(),
            stepTitleBuilder: (index) {
              final m = activity.activity.keys.elementAt(index);
              return DateFormat.Hm().format(m.subtract(Duration(minutes: 5)));
            },
            legendChildrenBuilder: (spotIndex, touchedSpots) {
              final textStyle = TextStyle(
                fontSize: 12.0,
                color: Theme.of(context).colorScheme.background,
              );
              if (true) {
                var items = List<LineTooltipItem>.generate(
                    activity.clients.length, (index) {
                  final client = activity.clients.elementAt(index);
                  final hits = activity.byClient[client]!
                      .elementAt(touchedSpots.first.x.toInt());
                  var localSpans = [
                    TextSpan(
                        text: '\u25A0 ',
                        style: TextStyle(
                            color: _chartColors
                                .elementAt(index % _chartColors.length))),
                    TextSpan(
                      text: (client.name.isNotEmpty ? client.name : client.ip) +
                          ': ',
                    ),
                    TextSpan(
                      text: hits.toString(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ];

                  if (index == 0) {
                    localSpans.insert(
                        0,
                        TextSpan(
                          text: activity.activity.keys
                                  .elementAt(spotIndex)
                                  .beforeAfter(const Duration(minutes: 5)) +
                              '\n',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ));
                  }

                  return LineTooltipItem(
                    // 'Pls here ${client.ip}',
                    '', textStyle,
                    // textAlign: TextAlign.end,
                    children: localSpans,
                  );
                });

                return items;
              }
            },
          ),
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (e, s) => Text(e.toString()),
    );
    return Card(
      child: ExpandableDashboardTile(
        title,
        leading: GridIcon(KIcons.clientActivity),
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
