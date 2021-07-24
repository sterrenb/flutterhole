import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/entities/settings_entities.dart';
import 'package:flutterhole_web/features/home/dashboard_tiles.dart';
import 'package:flutterhole_web/features/home/details_tiles.dart';
import 'package:flutterhole_web/features/home/memory_tile.dart';
import 'package:flutterhole_web/features/home/query_types_tile.dart';
import 'package:flutterhole_web/features/home/summary_tiles.dart';
import 'package:flutterhole_web/features/home/versions_tile.dart';
import 'package:flutterhole_web/features/layout/periodic_widget.dart';
import 'package:flutterhole_web/features/models/settings_models.dart';
import 'package:flutterhole_web/features/pihole/pi_status.dart';
import 'package:flutterhole_web/features/routing/app_router.gr.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:flutterhole_web/pihole_endpoint_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pihole_api/pihole_api.dart';
import 'package:refreshables/refreshables.dart';

import 'chart_tiles.dart';

extension DashboardIDX on DashboardID {
  Widget get widget {
    switch (this) {
      case DashboardID.versions:
        return const VersionsTile();
      case DashboardID.totalQueries:
        return const TotalQueriesTile();
      case DashboardID.queriesBlocked:
        return const QueriesBlockedTile();
      case DashboardID.percentBlocked:
        return const PercentBlockedTile();
      case DashboardID.domainsOnBlocklist:
        return const DomainsOnBlocklistTile();
      case DashboardID.queriesOverTime:
        return const QueriesOverTimeTile();
      case DashboardID.clientActivity:
        return const ClientActivityTile();
      case DashboardID.memory:
        return const MemoryTile();
      case DashboardID.queryTypes:
        return const QueryTypesTileTwo();
      case DashboardID.forwardDestinations:
        return const ForwardDestinationsTileTwo();
      case DashboardID.topPermittedDomains:
        return const TopPermittedDomainsTile();
      case DashboardID.topBlockedDomains:
        return const TopBlockedDomainsTile();
      case DashboardID.selectTiles:
        return const SelectTilesTile();
      case DashboardID.logs:
        return const LogsTile();
      case DashboardID.temperature:
        return const TempTile();
    }
  }
}

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

typedef DashRefreshCallback = Future<dynamic> Function(BuildContext context);

class DashboardGrid extends HookWidget {
  const DashboardGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dashboardSettings =
        useProvider(settingsNotifierProvider).active.dashboardSettings;
    final tiles = dashboardSettings.entries;
    final activeParams = useProvider(activePiParamsProvider);

    // TODO deprecate [params]
    // TODO only refresh tiles that are active
    Future<void> onDashboardRefresh(PiholeRepositoryParams params) async {
      final homeIsActive = context.router.isRouteActive(HomeRoute.name);
      if (homeIsActive) {
        // context.refresh(clientActivityOverTimeProvider(pi));
        // context.read(piholeStatusNotifierProvider.notifier).ping();
        // context.read(logNotifierProvider.notifier).log(fakeLogCall());
        context
            .refresh(piDetailsProvider(context.read(activePiParamsProvider)));
        context
            .refresh(piSummaryProvider(context.read(activePiParamsProvider)));
        context.refresh(
            queriesOverTimeProvider(context.read(activePiParamsProvider)));
        context.refresh(clientActivityOverTimeProvider(
            context.read(activePiParamsProvider)));
      }
    }

    useAsyncEffect(() {
      context.read(piholeStatusNotifierProvider.notifier).ping();
    }, keys: []);

    return PerHookWidget(
      onTimer: (timer) {
        onDashboardRefresh(activeParams);
      },
      child: tiles.any((element) => element.enabled)
          ? RefreshableGridBuilder(
              crossAxisCount:
                  (MediaQuery.of(context).orientation == Orientation.landscape)
                      ? 8
                      : 4,
              spacing: kGridSpacing,
              onRefresh: () => onDashboardRefresh(activeParams),
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
                debugPrint('rendering default tile with count(4, 1)');
                // ignore: prefer_const_constructors
                return StaggeredTile.count(4, 1);
              }).toList(),
              children: tiles.where((element) => element.enabled).map((e) {
                return e.id.widget;
              }).toList(),
            )
          : const Center(child: SelectTilesTile()),
    );
  }
}
