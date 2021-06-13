import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutterhole_web/chart_tiles.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/features/home/dashboard_tiles.dart';
import 'package:flutterhole_web/features/home/memory_tile.dart';
import 'package:flutterhole_web/features/home/query_types_tile.dart';
import 'package:flutterhole_web/features/home/temperature_tile.dart';
import 'package:flutterhole_web/features/home/versions_tile.dart';
import 'package:flutterhole_web/features/routing/app_router.gr.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:flutterhole_web/top_level_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

final Map<DashboardID, StaggeredTile> staggeredTile =
    DashboardID.values.asMap().map((index, id) {
  final tile = (id) {
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
      default:
        return const StaggeredTile.count(4, 1);
    }
  }(id);

  return MapEntry(id, tile);
});

// final Map<DashboardID, StaggeredTile> staggeredTiles = {
//   DashboardID.Versions: const StaggeredTile.fit(4),
//   DashboardID.TotalQueries: const StaggeredTile.count(4, 1),
//   DashboardID.QueriesBlocked: const StaggeredTile.count(4, 1),
//   DashboardID.PercentBlocked: const StaggeredTile.count(4, 1),
//   DashboardID.DomainsOnBlocklist: const StaggeredTile.count(4, 1),
//   DashboardID.QueriesBarChart: const StaggeredTile.fit(4),
//   DashboardID.ClientActivityBarChart: const StaggeredTile.fit(4),
//   DashboardID.Temperature: const StaggeredTile.count(2, 2),
//   DashboardID.Memory: const StaggeredTile.count(2, 2),
//   DashboardID.QueryTypes: const StaggeredTile.count(4, 2),
//   DashboardID.ForwardDestinations: const StaggeredTile.count(4, 2),
//   DashboardID.TopPermittedDomains: const StaggeredTile.fit(4),
//   DashboardID.TopBlockedDomains: const StaggeredTile.fit(4),
// };

// final dashboardProvider =
//     StateProvider<List<DashboardEntry>>((ref) => _dashboardProviderDefault);

class SelectTilesButtonTile extends HookWidget {
  const SelectTilesButtonTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: Icon(KIcons.selectDashboardTiles),
      onPressed: () {
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
        // Navigator.of(context).push(MaterialPageRoute(
        //   builder: (BuildContext context) => const DashboardSettingsPage(),
        //   // fullscreenDialog: true,
        // ));
      },
      label: Text('Select tiles'.toUpperCase()),
    );
  }
}

class DashboardGrid extends HookWidget {
  const DashboardGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final dashboardSettings = DashboardSettings.initial();
    final dashboardSettings =
        useProvider(settingsNotifierProvider).active.dashboardSettings;
    final tiles = dashboardSettings.entries;
    // final tiles = useProvider(dashboardProvider);
    if (5 > 6)
      return ListView(
        children: [
          TextButton(
              onPressed: () {
                context.read(piholeStatusNotifierProvider.notifier).ping();
              },
              child: Text('ping')),
        ],
      );

    return tiles.any((element) => element.enabled)
        ? TheGrid(
            // tiles: [
            //   const StaggeredTile.count(4, 1),
            //   ...tiles.state
            //       .where((element) => element.enabled)
            //       .map((e) => e.tile),
            //   const StaggeredTile.count(4, 1),
            // ].toList(),
            tiles: dashboardSettings.entries
                .where((element) => element.enabled)
                .map<StaggeredTile>((entry) {
              final x = staggeredTile.containsKey(entry.id)
                  ? staggeredTile[entry.id]
                  : null;

              if (x != null) return x;
              return const StaggeredTile.count(4, 1);
            }).toList(),
            // children: tiles.map((e) {
            children: tiles.where((element) => element.enabled).map((e) {
              switch (e.id) {
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
                  return const SelectTilesButtonTile();
              }
            }).toList(),
          )
        : Center(child: SelectTilesButtonTile());
  }
}

class TheGrid extends HookWidget {
  const TheGrid({
    Key? key,
    required this.tiles,
    required this.children,
  })  : assert(tiles.length == children.length),
        super(key: key);

  final List<StaggeredTile> tiles;
  final List<Widget> children;

  // final RefreshController controller = RefreshController();

  @override
  Widget build(BuildContext context) {
    final controller = useState(RefreshController());

    void onRefresh() async {
      print('grid refresh');
      // await Future.delayed(Duration(seconds: 1));
      // context.refresh(piDetailsProvider(context.read(activePiProvider).state));
      controller.value.refreshCompleted();
    }

    return SmartRefresher(
      controller: controller.value,
      onRefresh: onRefresh,
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
