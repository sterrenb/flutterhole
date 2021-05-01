import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutterhole_web/chart_tiles.dart';
import 'package:flutterhole_web/dashboard_tiles.dart';
import 'package:flutterhole_web/features/home/home_app_bar.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

List<StaggeredTile> _staggeredTiles = <StaggeredTile>[
  const StaggeredTile.count(4, 3),
  const StaggeredTile.count(4, 1),
  const StaggeredTile.count(4, 1),
  const StaggeredTile.count(4, 1),
  const StaggeredTile.count(4, 1),
  const StaggeredTile.count(2, 2),
  const StaggeredTile.count(2, 2),
  const StaggeredTile.count(4, 3),
  const StaggeredTile.count(4, 3),
];
List<Widget> _tiles = <Widget>[
  QueriesOverTimeTile(),
  TotalQueriesTile(),
  QueriesBlockedTile(),
  PercentBlockedTile(),
  DomainsOnBlocklistTile(),
  PiTemperatureTile(),
  PiMemoryTile(),
  QueryTypesTile(),
  ForwardDestinationsTile(),
];

class RefreshableHomeGrid extends StatefulWidget {
  @override
  _RefreshableHomeGridState createState() => _RefreshableHomeGridState();
}

class _RefreshableHomeGridState extends State<RefreshableHomeGrid> {
  final RefreshController controller = RefreshController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onRefresh() async {
    await Future.wait([
      context.refresh(summaryProvider),
      context.refresh(queryTypesProvider),
      context.refresh(forwardDestinationsProvider),
      context.refresh(piDetailsProvider),
      Future.delayed(Duration(seconds: 1)),
    ], eagerError: true)
        .catchError((e) {
      print('oh no: $e');
    });

    controller.refreshCompleted();
  }

  StaggeredGridView buildStaggeredGridView(BuildContext context) {
    return StaggeredGridView.count(
      crossAxisCount: 4,
      staggeredTiles: _staggeredTiles,
      children: _tiles,
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
      padding: const EdgeInsets.all(4.0),
      physics: const BouncingScrollPhysics(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration(
      enableBallisticLoad: true,
      enableRefreshVibrate: true,
      headerBuilder: () => WaterDropMaterialHeader(
          // color: Colors.orange,
          ),
      child: SmartRefresher(
        controller: controller,
        enablePullDown: true,
        onRefresh: onRefresh,
        child: buildStaggeredGridView(context),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(),
      body: RefreshableHomeGrid(),
    );
  }
}
