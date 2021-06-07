import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutterhole_web/features/home/dashboard_tiles.dart';
import 'package:flutterhole_web/features/home/home_app_bar.dart';
import 'package:flutterhole_web/features/home/memory_tile.dart';
import 'package:flutterhole_web/features/home/temperature_tile.dart';
import 'package:flutterhole_web/features/pihole/pi_status.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RefreshableHomeGrid extends StatefulWidget {
  @override
  _RefreshableHomeGridState createState() => _RefreshableHomeGridState();
}

class _RefreshableHomeGridState extends State<RefreshableHomeGrid> {
  final RefreshController controller = RefreshController();

  void onRefresh() async {
    final pi = context.read(activePiProvider).state;
    await Future.wait<void>([
      context.refresh(piSummaryProvider(pi)),
      context.refresh(queryTypesProvider(pi)),
      context.refresh(topItemsProvider(pi)),
      // context.refresh(forwardDestinationsProvider),
      context.refresh(piDetailsProvider(pi)),
      // context.read(piholeStatusNotifierProvider.notifier).fetchStatus(),
    ], eagerError: true)
        .catchError((e) {
      print('oh no: $e');
      controller.refreshCompleted();
    });

    controller.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration(
      enableBallisticLoad: true,
      enableRefreshVibrate: true,
      enableLoadingWhenFailed: true,
      dragSpeedRatio: 1.5,
      headerBuilder: () => WaterDropMaterialHeader(
          // color: Colors.orange,
          ),
      child: SmartRefresher(
        controller: controller,
        enablePullDown: true,
        onRefresh: onRefresh,
        child: StaggeredGridView.count(
          crossAxisCount:
              (MediaQuery.of(context).orientation == Orientation.landscape)
                  ? 8
                  : 4,
          // 4,
          staggeredTiles: [
            // const StaggeredTile.count(4, 2),
            const StaggeredTile.count(4, 1),
            const StaggeredTile.count(4, 1),
            const StaggeredTile.count(4, 1),
            const StaggeredTile.count(4, 1),
            const StaggeredTile.count(2, 2),
            const StaggeredTile.count(2, 2),
            // const StaggeredTile.count(4, 3),

            const StaggeredTile.fit(4),
            const StaggeredTile.fit(4),
            // const StaggeredTile.count(4, 3),
            // const StaggeredTile.count(4, 3),
          ],
          children: [
            TotalQueriesTile(),
            QueriesBlockedTile(),
            PercentBlockedTile(),
            DomainsOnBlocklistTile(),
            TemperatureTile(),
            MemoryTile(),
            // QueriesOverTimeTile(),
            TopPermittedDomainsTile(),
            TopBlockedDomainsTile(),

            // QueryTypesTile(),
            // ForwardDestinationsTile(),
          ],
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
          padding: const EdgeInsets.all(4.0),
          physics: const BouncingScrollPhysics(),
        ),
      ),
    );
  }
}

class HomeScreen extends HookWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      print('home build first');
      context.read(piholeStatusNotifierProvider.notifier).fetchStatus();
    }, [piholeStatusNotifierProvider]);

    return Scaffold(
      appBar: HomeAppBar(),
      body: RefreshableHomeGrid(),
      floatingActionButton: PiToggleFloatingActionButton(),
    );
  }
}
