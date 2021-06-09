import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutterhole_web/chart_tiles.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/features/home/dashboard_tiles.dart';
import 'package:flutterhole_web/features/home/memory_tile.dart';
import 'package:flutterhole_web/features/home/temperature_tile.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

final List<DashboardEntry> _dashboardProviderDefault = {
  DashboardID.TotalQueries: const StaggeredTile.count(4, 1),
  DashboardID.QueriesBlocked: const StaggeredTile.count(4, 1),
  DashboardID.PercentBlocked: const StaggeredTile.count(4, 1),
  DashboardID.DomainsOnBlocklist: const StaggeredTile.count(4, 1),
  DashboardID.QueriesBarChart: const StaggeredTile.fit(4),
  DashboardID.ClientActivityBarChart: const StaggeredTile.fit(4),
  DashboardID.Temperature: const StaggeredTile.count(2, 2),
  DashboardID.Memory: const StaggeredTile.count(2, 2),
  DashboardID.QueryTypes: const StaggeredTile.count(4, 2),
  DashboardID.ForwardDestinations: const StaggeredTile.count(4, 2),
  DashboardID.TopPermittedDomains: const StaggeredTile.fit(4),
  DashboardID.TopBlockedDomains: const StaggeredTile.fit(4),
}
    .entries
    .map((e) => DashboardEntry(id: e.key, tile: e.value, enabled: true))
    .toList();

final dashboardProvider =
    StateProvider<List<DashboardEntry>>((ref) => _dashboardProviderDefault);

class DashTog extends HookWidget {
  const DashTog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: Icon(KIcons.selectDashboardTiles),
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => const DashSelectScreen(),
          // fullscreenDialog: true,
        ));
      },
      label: Text('Select tiles'.toUpperCase()),
    );
  }
}

class DashboardGrid extends HookWidget {
  const DashboardGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tiles = useProvider(dashboardProvider);
    return tiles.state.any((element) => element.enabled)
        ? TheGrid(
            tiles: [
              ...tiles.state
                  .where((element) => element.enabled)
                  .map((e) => e.tile),
              const StaggeredTile.count(4, 1),
            ].toList(),
            children: <Widget>[
              ...tiles.state.where((element) => element.enabled).map((e) {
                switch (e.id) {
                  case DashboardID.TotalQueries:
                    return TotalQueriesTile();
                  case DashboardID.QueriesBlocked:
                    return QueriesBlockedTile();
                  case DashboardID.PercentBlocked:
                    return PercentBlockedTile();
                  case DashboardID.DomainsOnBlocklist:
                    return DomainsOnBlocklistTile();
                  case DashboardID.QueriesBarChart:
                    return QueriesBarChartTile();
                  case DashboardID.ClientActivityBarChart:
                    return ClientActivityBarChartTile();
                  case DashboardID.Temperature:
                    return TemperatureTile();
                  case DashboardID.Memory:
                    return MemoryTile();
                  case DashboardID.QueryTypes:
                    return QueryTypesTile();
                  case DashboardID.ForwardDestinations:
                    return ForwardDestinationsTile();
                  case DashboardID.TopPermittedDomains:
                    return TopPermittedDomainsTile();
                  case DashboardID.TopBlockedDomains:
                    return TopBlockedDomainsTile();
                }
              }),
              DashTog(),
            ].toList(),
          )
        : Center(child: DashTog());
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
      child: StaggeredGridView.count(
        crossAxisCount:
            (MediaQuery.of(context).orientation == Orientation.landscape)
                ? 8
                : 4,
        staggeredTiles: this.tiles,
        children: this.children,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        padding: const EdgeInsets.all(4.0),
        physics: const BouncingScrollPhysics(),
      ),
    );
  }
}

class DashSelectScreen extends HookWidget {
  const DashSelectScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select tiles'),
        actions: [
          IconButton(
              tooltip: 'Reset to default',
              onPressed: () {
                context.read(dashboardProvider).state =
                    _dashboardProviderDefault;
              },
              icon: Icon(
                Icons.update,
              ))
        ],
      ),
      body: HookBuilder(builder: (context) {
        final dash = useProvider(dashboardProvider);
        return ReorderableListView(
            buildDefaultDragHandles: false,
            children: <Widget>[
              for (int index = 0; index < dash.state.length; index++)
                GridSelectItem(
                  index,
                  key: Key('$index'),
                )
            ],
            onReorder: (oldIndex, newIndex) {
              print('$oldIndex, $newIndex');
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }

              final list =
                  List<DashboardEntry>.from(dash.state, growable: true);
              final item = list.removeAt(oldIndex);
              list.insert(newIndex, item);
              dash.state = list;
            });
      }),
    );
  }
}

class GridSelectItem extends HookWidget {
  const GridSelectItem(this.index, {Key? key}) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    final dash = useProvider(dashboardProvider);
    final entry = dash.state.elementAt(index);
    return Column(
      children: [
        Divider(height: 0),
        ListTile(
          title: Text(
            entry.id.toString().split('.').last,
            style: TextStyle(
                color: entry.enabled ? null : Theme.of(context).disabledColor),
          ),
          leading: DashboardTileIcon((DashboardID id) {
            switch (id) {
              case DashboardID.TotalQueries:
                return KIcons.totalQueries;
              case DashboardID.QueriesBlocked:
                return KIcons.queriesBlocked;
              case DashboardID.PercentBlocked:
                return KIcons.percentBlocked;
              case DashboardID.DomainsOnBlocklist:
                return KIcons.domainsOnBlocklist;
              case DashboardID.QueriesBarChart:
                return KIcons.queriesOverTime;
              case DashboardID.ClientActivityBarChart:
                return KIcons.clientActivity;
              case DashboardID.Temperature:
                return KIcons.temperatureReading;
              case DashboardID.Memory:
                return KIcons.memoryUsage;
              case DashboardID.QueryTypes:
                return KIcons.memoryUsage;
              case DashboardID.ForwardDestinations:
                return KIcons.memoryUsage;
              case DashboardID.TopPermittedDomains:
                return KIcons.domainsPermittedTile;
              case DashboardID.TopBlockedDomains:
                return KIcons.domainsBlockedTile;
            }
          }(entry.id)),
          trailing: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Tooltip(
                message: 'Toggle visibility',
                child: Checkbox(
                  value: entry.enabled,
                  onChanged: (_) {
                    List<DashboardEntry> l = List.from(dash.state);
                    final newEntry = l.elementAt(index);
                    l[index] = newEntry.copyWith(enabled: !newEntry.enabled);
                    dash.state = l;
                  },
                ),
              ),
              ReorderableDragStartListener(
                index: index,
                child: IconButton(
                  onPressed: null,
                  icon: Icon(Icons.drag_handle),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 0),
      ],
    );
  }
}
