import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutterhole_web/chart_tiles.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/dashboard_tiles.dart';
import 'package:flutterhole_web/dialogs.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/periodic_widget.dart';
import 'package:flutterhole_web/pi_temperature_text.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:flutterhole_web/settings_screen.dart';
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

class PiStatusIcon extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final piStatus = useProvider(piStatusProvider);

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(
            KIcons.dot,
            color: piStatus.when(
              data: (status) =>
                  status == PiStatus.enabled ? Colors.green : Colors.orange,
              loading: () => Colors.blueGrey,
              error: (e, s) => Colors.red,
            ),
            size: 8.0,
          ),
          tooltip: piStatus.when(
            data: (status) =>
                status == PiStatus.enabled ? 'Enabled' : 'Disabled',
            loading: () => 'Loading',
            error: (e, s) => 'Error: $e',
          ),
          onPressed: () {},
        ),
        IgnorePointer(
          child: AnimatedOpacity(
            duration: kThemeAnimationDuration,
            opacity: piStatus.maybeWhen(loading: () => 1.0, orElse: () => 0.0),
            child: SizedBox(
              width: 14.0,
              height: 14.0,
              child: CircularProgressIndicator(strokeWidth: 2.0),
            ),
          ),
        ),
      ],
    );
  }
}

class ActivePiTitle extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final pi = useProvider(activePiProvider);
    return Text(pi.state.title);
  }
}

class HomeAppBar extends HookWidget implements PreferredSizeWidget {
  const HomeAppBar({Key key})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    final updateFrequency = useProvider(updateFrequencyProvider);

    print('building HomeAppBar');
    return AppBar(
      elevation: 0.0,
      title: Row(
        children: [
          ActivePiTitle(),
          PiStatusIcon(),
          PeriodicWidget(
            child: Container(),
            // child: PiTemperatureText(),
            duration: updateFrequency.state,
            onTimer: (timer) {
              // print('hi ${timer.tick}');
              context.refresh(piDetailsProvider);
            },
          ),
        ],
      ),
      actions: [
        HomeRefreshIcon(),
        IconButton(
          icon: Icon(KIcons.pihole),
          tooltip: 'Select Pi-hole',
          onPressed: () => showActivePiDialog(context, context.read),
        ),
        IconButton(
            icon: Icon(KIcons.settings),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (BuildContext context) => SettingsScreen()),
                )),
      ],
    );
  }
}

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
    print('wee');
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

class HomeRefreshIcon extends HookWidget {
  @override
  Widget build(BuildContext context) => IconButton(
        icon: Icon(KIcons.refresh),
        onPressed: () {
          context.refresh(summaryProvider);
          context.refresh(queryTypesProvider);
          context.refresh(forwardDestinationsProvider);
          context.refresh(piDetailsProvider);
        },
      );
}
