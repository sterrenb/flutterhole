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
import 'package:flutterhole_web/features/pihole/active_pi.dart';
import 'package:flutterhole_web/features/routing/app_router.gr.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:flutterhole_web/top_level_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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

final Map<DashboardID, StaggeredTile> staggeredTile =
    DashboardID.values.asMap().map((index, id) => MapEntry(
        id,
        (id) {
          switch (id) {
            case DashboardID.SelectTiles:
              return const StaggeredTile.count(4, 1);
            case DashboardID.TotalQueries:
              return const StaggeredTile.count(4, 1);
            case DashboardID.QueriesBlocked:
              return const StaggeredTile.count(4, 1);
            case DashboardID.PercentBlocked:
              return const StaggeredTile.count(4, 1);
            case DashboardID.DomainsOnBlocklist:
              return const StaggeredTile.count(4, 1);
            case DashboardID.QueriesBarChart:
              return const StaggeredTile.fit(4);
            case DashboardID.ClientActivityBarChart:
              return const StaggeredTile.fit(4);
            case DashboardID.Temperature:
              return const StaggeredTile.count(2, 2);
            case DashboardID.Memory:
              return const StaggeredTile.count(2, 2);
            case DashboardID.QueryTypes:
              return const StaggeredTile.count(4, 2);
            case DashboardID.ForwardDestinations:
              return const StaggeredTile.count(4, 2);
            case DashboardID.TopPermittedDomains:
              return const StaggeredTile.fit(4);
            case DashboardID.TopBlockedDomains:
              return const StaggeredTile.fit(4);
            case DashboardID.Versions:
              return const StaggeredTile.fit(4);
            case DashboardID.Versions:
              return const StaggeredTile.fit(4);
            case DashboardID.Logs:
              return const StaggeredTile.count(4, 3);
            default:
              return const StaggeredTile.count(4, 1);
          }
        }(id)));

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
                print('updating');
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

class DashboardGrid extends HookWidget {
  const DashboardGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dashboardSettings =
        useProvider(settingsNotifierProvider).active.dashboardSettings;
    final tiles = dashboardSettings.entries;
    final activePi = useProvider(activePiProvider);

    final mounted = useIsMounted();

    final VoidFutureCallBack onRefresh = () async {
      print('refreshing from DashboardGrid: ${mounted()}');

      if (mounted()) {
        // TODO this causes some initial build issues
        await Future.delayed(Duration(seconds: 1));
        context.read(piholeStatusNotifierProvider.notifier).ping();

        context.refresh(piSummaryProvider(context.read(activePiProvider)));
        context.refresh(activePiDetailsProvider);
        context.refresh(activeClientActivityProvider);
      }
    };

    useEffect(() {
      print('triggering refresh for new pi ${activePi.title}');
      // onRefresh();
    }, [activePi]);

    return PerHookWidget(
      onTimer: (timer) {
        // print('tick ${timer.tick}');
        if (context.router.isRouteActive(HomeRoute.name)) {
          onRefresh();
        }
      },
      child: tiles.any((element) => element.enabled)
          ? _DashboardGridBuilder(
              onRefresh: onRefresh,
              tiles: dashboardSettings.entries
                  .where((element) => element.enabled)
                  .map<StaggeredTile>((entry) {
                final matchingTile = staggeredTile.containsKey(entry.id)
                    ? staggeredTile[entry.id]
                    : null;

                if (matchingTile != null) return matchingTile;
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

class _DashboardGridBuilder extends HookWidget {
  const _DashboardGridBuilder({
    Key? key,
    required this.onRefresh,
    required this.tiles,
    required this.children,
  })  : assert(tiles.length == children.length),
        super(key: key);

  final VoidFutureCallBack onRefresh;
  final List<StaggeredTile> tiles;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final controller = useState(RefreshController());

    void _onRefresh() async {
      await onRefresh();
      controller.value.refreshCompleted();
    }

    return SmartRefresher(
      controller: controller.value,
      onRefresh: _onRefresh,
      enablePullDown: true,
      child: StaggeredGridView.count(
        crossAxisCount:
            (MediaQuery.of(context).orientation == Orientation.landscape)
                ? 8
                : 4,
        staggeredTiles: this.tiles,
        children: this.children,
        mainAxisSpacing: kGridSpacing,
        crossAxisSpacing: kGridSpacing,
        padding: const EdgeInsets.all(kGridSpacing),
        physics: const BouncingScrollPhysics(),
      ),
    );
  }
}
