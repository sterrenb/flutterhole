import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutterhole_web/chart_tiles.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/entities/settings_entities.dart';
import 'package:flutterhole_web/features/home/dashboard_tiles.dart';
import 'package:flutterhole_web/features/home/details_tiles.dart';
import 'package:flutterhole_web/features/home/memory_tile.dart';
import 'package:flutterhole_web/features/home/query_types_tile.dart';
import 'package:flutterhole_web/features/home/summary_tiles.dart';
import 'package:flutterhole_web/features/home/temperature_tile.dart';
import 'package:flutterhole_web/features/home/versions_tile.dart';
import 'package:flutterhole_web/features/layout/periodic_widget.dart';
import 'package:flutterhole_web/features/logging/loggers.dart';
import 'package:flutterhole_web/features/models/settings_models.dart';
import 'package:flutterhole_web/features/pihole/pi_status.dart';
import 'package:flutterhole_web/features/routing/app_router.gr.dart';
import 'package:flutterhole_web/features/settings/developer_widgets.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:flutterhole_web/pihole_endpoint_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pihole_api/pihole_api.dart';
import 'package:refreshables/refreshables.dart';

extension DashboardIDX on DashboardID {
  Widget get widget {
    switch (this) {
      case DashboardID.Versions:
        return const VersionsTile();
      case DashboardID.TotalQueries:
        return const TotalQueriesTile();
      case DashboardID.QueriesBlocked:
        return const QueriesBlockedTile();
      case DashboardID.PercentBlocked:
        return const PercentBlockedTile();
      case DashboardID.DomainsOnBlocklist:
        return const DomainsOnBlocklistTile();
      case DashboardID.QueriesBarChart:
        return const QueriesBarChartTile();
      case DashboardID.ClientActivityBarChart:
        return const ClientActivityBarChartTile();
      case DashboardID.Temperature:
        return const TemperatureTile();
      case DashboardID.Memory:
        return const MemoryTile();
      case DashboardID.QueryTypes:
        return const QueryTypesTileTwo();
      case DashboardID.ForwardDestinations:
        return const ForwardDestinationsTileTwo();
      case DashboardID.TopPermittedDomains:
        return const TopPermittedDomainsTile();
      case DashboardID.TopBlockedDomains:
        return const TopBlockedDomainsTile();
      case DashboardID.SelectTiles:
        return const SelectTilesTile();
      case DashboardID.Logs:
        return const LogsTile();
      case DashboardID.TempTile:
        return const TempTile();
    }
  }
}

// final Map<DashboardID, StaggeredTile> staggeredTile =
//     DashboardID.values.asMap().map((index, id) => MapEntry(
//         id,
//         (id) {
//           switch (id) {
//             case DashboardID.SelectTiles:
//               return const StaggeredTile.count(4, 1);
//             case DashboardID.TotalQueries:
//               return const StaggeredTile.count(4, 1);
//             case DashboardID.QueriesBlocked:
//               return const StaggeredTile.count(4, 1);
//             case DashboardID.PercentBlocked:
//               return const StaggeredTile.count(4, 1);
//             case DashboardID.DomainsOnBlocklist:
//               return const StaggeredTile.count(4, 1);
//             case DashboardID.QueriesBarChart:
//               return const StaggeredTile.fit(4);
//             case DashboardID.ClientActivityBarChart:
//               return const StaggeredTile.fit(4);
//             case DashboardID.Temperature:
//               return const StaggeredTile.count(2, 2);
//             case DashboardID.Memory:
//               return const StaggeredTile.count(2, 2);
//             case DashboardID.QueryTypes:
//               return const StaggeredTile.count(4, 2);
//             case DashboardID.ForwardDestinations:
//               return const StaggeredTile.count(4, 2);
//             case DashboardID.TopPermittedDomains:
//               return const StaggeredTile.fit(4);
//             case DashboardID.TopBlockedDomains:
//               return const StaggeredTile.fit(4);
//             case DashboardID.Versions:
//               return const StaggeredTile.fit(4);
//             case DashboardID.Versions:
//               return const StaggeredTile.fit(4);
//             case DashboardID.Logs:
//               return StaggeredTile.extent(
//                   4, (kLogsDashboardCacheLength + 2) * kToolbarHeight);
//             // return const StaggeredTile.fit(4);
//             default:
//               return const StaggeredTile.count(4, 1);
//           }
//         }(id)));

class SelectTilesTile extends HookWidget {
  const SelectTilesTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: Icon(
        KIcons.selectDashboardTiles,
        color: Theme.of(context).accentColor,
      ),
      onPressed: () {
        // context.read(loggerProvider('tile')).log(Level.INFO, 'Hi there');
        // context.read(logNotifierProvider.notifier).log(Level.INFO, 'Byeee');
        // return;
        context.router.push(
          DashboardSettingsRoute(
              initial: context.read(activePiProvider).dashboardSettings,
              onSave: (update) {
                context
                    .read(settingsNotifierProvider.notifier)
                    .updateDashboardEntries(update.entries);
              }),
        );
      },
      // style: ButtonStyle(
      //   foregroundColor:
      //       MaterialStateColor.resolveWith((states) => Colors.green),
      // ),
      label: Text(
        'Select tiles'.toUpperCase(),
        style: TextStyle(color: Theme.of(context).accentColor),
      ),
    );
  }
}

typedef Future<dynamic> DashRefreshCallback(BuildContext context);

class DashboardGrid extends HookWidget {
  const DashboardGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dashboardSettings =
        useProvider(settingsNotifierProvider).active.dashboardSettings;
    final tiles = dashboardSettings.entries;
    final activeParams = useProvider(activePiParamsProvider);
    final useAggressiveFetching = useProvider(useAggressiveFetchingProvider);

    Future<void> onRefresh(PiholeRepositoryParams pi) async {
      final homeIsActive = context.router.isRouteActive(HomeRoute.name);
      // print('refreshing from DashboardGrid: $homeIsActive');
      if (homeIsActive) {
        // Future.microtask(
        //     () => context.read(piholeStatusNotifierProvider.notifier).ping());
        // final x = Future.microtask(
        //     () => context.refresh(clientActivityOverTimeProvider(pi)));

        context.refresh(clientActivityOverTimeProvider(pi));
        context.read(piholeStatusNotifierProvider.notifier).ping();
        context.read(logNotifierProvider.notifier).log(fakeLogCall());
        if (5 < 6) return;

        // context.refresh(clientActivityOverTimeProvider(activePi))
        // List futures = [

        // List<DashRefreshCallback> futures = [
        //       () async {
        //     print('done bois');
        //
        //     context.log(LogCall(
        //       source: 'dash',
        //       level: LogLevel.error,
        //       message: 'Testing done',
        //     ));
        //   }
        // ];
        // if (false)
        // List<DashRefreshCallback> futures = [
        //   (context) =>
        //       context.read(piholeStatusNotifierProvider.notifier).ping(),
        //   // () => context.refresh(piSummaryProvider(activePi)),
        //   (context) =>
        //       context.refresh(clientActivityOverTimeProvider(pi)),
        //   (context) => context.refresh(queryTypesProvider(pi)),
        //   // () => c.refresh(piDetailsProvider(activePi)),
        // ];
        //
        // if (useAggressiveFetching) {
        //   final real = futures.map((e) => e(context)).toList();
        //   print('directly awaiting ${real.length} futures');
        //   try {
        //     await Future.wait(real, eagerError: true);
        //   } catch (e) {
        //     if (e == PiholeApiFailure.cancelled()) {
        //       return;
        //     } else {
        //       context.log(LogCall(
        //           source: 'dashboard',
        //           level: LogLevel.warning,
        //           message: 'refresh failed',
        //           error: e));
        //     }
        //   }
        // } else {
        //   for (final f in futures) {
        //     await Future.delayed(kRefreshDuration);
        //     await f(c);
        //   }
        //
        //   // context.log(LogCall(
        //   //     source: 'dashboard',
        //   //     level: LogLevel.debug,
        //   //     message: 'Done refreshing',
        //   //     error: {'licc': 'meee'}));
        // }
      }
    }

    ;

    // useAsyncEffect(() {
    //   print('triggering refresh for new pi ${activePi.baseApiUrl}');
    //   onRefresh(activePi);
    // }, keys: [activePi.baseApiUrl]);

    useAsyncEffect(() {
      print('triggering initial ping');
      context.read(piholeStatusNotifierProvider.notifier).ping();
    }, keys: []);

    return PerHookWidget(
      onTimer: (timer) {
        onRefresh(activeParams);
      },
      child: tiles.any((element) => element.enabled)
          ? RefreshableGridBuilder(
              crossAxisCount:
                  (MediaQuery.of(context).orientation == Orientation.landscape)
                      ? 8
                      : 4,
              spacing: kGridSpacing,
              onRefresh: () => onRefresh(activeParams),
              tiles: dashboardSettings.entries
                  .where((element) => element.enabled)
                  .map<StaggeredTile>((entry) {
                final matchingTile =
                    DashboardTileConstraints.defaults.containsKey(entry.id)
                        ? DashboardTileConstraints.defaults[entry.id]
                        : null;

                if (matchingTile != null) {
                  return matchingTile.when(
                    count: (c, m) => StaggeredTile.count(c, m.toDouble()),
                    extent: (c, m) => StaggeredTile.extent(c, m),
                    fit: (c) => StaggeredTile.fit(c),
                  );
                }
                return const StaggeredTile.count(4, 1);
              }).toList(),
              children: tiles.where((element) => element.enabled).map((e) {
                return e.id.widget;
              }).toList(),
            )
          : Center(child: SelectTilesTile()),
    );
  }
}
