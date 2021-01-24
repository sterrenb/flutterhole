import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/dashboard_tiles.dart';
import 'package:flutterhole_web/dialogs.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/periodic_widget.dart';
import 'package:flutterhole_web/pi_temperature_text.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:flutterhole_web/settings_screen.dart';
import 'package:hooks_riverpod/all.dart';

List<StaggeredTile> _staggeredTiles = <StaggeredTile>[
  const StaggeredTile.count(4, 1),
  const StaggeredTile.count(4, 1),
  const StaggeredTile.count(4, 1),
  const StaggeredTile.count(4, 1),
  const StaggeredTile.count(2, 2),
  const StaggeredTile.count(2, 2),
  // const StaggeredTile.count(4, 2),

  // const StaggeredTile.count(2, 2),
  // const StaggeredTile.count(2, 1),
  // const StaggeredTile.count(1, 2),
  // const StaggeredTile.count(1, 1),
  // const StaggeredTile.count(2, 2),
  // const StaggeredTile.count(1, 2),
  // const StaggeredTile.count(1, 1),
  // const StaggeredTile.count(3, 1),
  // const StaggeredTile.count(1, 1),
  // const StaggeredTile.count(4, 1),
];
List<Widget> _tiles = <Widget>[
  TotalQueriesTile(),
  QueriesBlockedTile(),
  // const _Example01Tile(Colors.green, Icons.widgets),
  PercentBlockedTile(),
  DomainsOnBlocklistTile(),
  PiTemperatureTile(),
  PiMemoryTile(),
  _Example01Tile(Colors.lightBlue, Icons.wifi),
  _Example01Tile(Colors.orange, Icons.panorama_wide_angle),
  _Example01Tile(Colors.redAccent, Icons.map),
  _Example01Tile(Colors.deepOrange, Icons.send),
  // const _Example01Tile(Colors.indigo, Icons.airline_seat_flat),
  // const _Example01Tile(Colors.red, Icons.bluetooth),
  // const _Example01Tile(Colors.pink, Icons.battery_alert),
  // const _Example01Tile(Colors.purple, Icons.desktop_windows),
  // const _Example01Tile(Colors.blue, Icons.radio),
];

class _Example01Tile extends StatelessWidget {
  const _Example01Tile(this.backgroundColor, this.iconData);

  final Color backgroundColor;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return new Card(
      color: backgroundColor,
      child: new InkWell(
        onTap: () {},
        child: new Center(
          child: new Padding(
            padding: const EdgeInsets.all(4.0),
            child: new Icon(
              iconData,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

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
      title: Row(
        children: [
          ActivePiTitle(),
          PiStatusIcon(),
          PeriodicWidget(
            child: PiTemperatureText(),
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

class HomeGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: OrientationBuilder(
        builder: (context, orientation) {
          return StaggeredGridView.count(
            crossAxisCount: orientation == Orientation.portrait ? 4 : 8,
            staggeredTiles: [..._staggeredTiles],
            children: [..._tiles],
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
            padding: const EdgeInsets.all(4.0),
          );
        },
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
      body: HomeGrid(),
    );
  }
}

class HomeRefreshIcon extends HookWidget {
  @override
  Widget build(BuildContext context) => IconButton(
        icon: Icon(KIcons.refresh),
        onPressed: () {
          context.refresh(summaryProvider);
          context.refresh(piDetailsProvider);
        },
      );
}
