import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutterhole/widgets/layout/grids.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class DemoDashboard extends HookWidget {
  const DemoDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StaggeredGrid.count(
      crossAxisCount: 4,
      axisDirection: AxisDirection.down,
      children: const [
        StaggeredGridTile.count(
            crossAxisCellCount: 3,
            mainAxisCellCount: 1,
            child: _ColorThemeCard(duration: Duration(seconds: 4))),
        StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 2,
            child: _ColorThemeCard(duration: Duration(seconds: 3))),
        StaggeredGridTile.count(
            crossAxisCellCount: 2,
            mainAxisCellCount: 1,
            child: _ColorThemeCard(duration: Duration(seconds: 2))),
        StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: _ColorThemeCard(duration: Duration(seconds: 3))),
        // StaggeredGridTile.count(
        //     crossAxisCellCount: 1,
        //     mainAxisCellCount: 1,
        //     child: _ColorThemeCard(duration: Duration(seconds: 2))),
        // StaggeredGridTile.count(
        //     crossAxisCellCount: 3,
        //     mainAxisCellCount: 1,
        //     child: _ColorThemeCard(duration: Duration(seconds: 5))),
      ],
    );
  }
}

final _random = Random();

class _ColorThemeCard extends StatelessWidget {
  const _ColorThemeCard({Key? key, required this.duration}) : super(key: key);

  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final colors = [
      t.colorScheme.primary,
      t.colorScheme.secondary,
      t.cardColor,
    ];
    return _ColorCard(
      duration: duration,
      colors: [
        ...List.filled(Colors.primaries.length ~/ 2,
            Theme.of(context).textTheme.bodyText2!.color!),
        ...Colors.primaries
      ],
    );
  }
}

class _ColorCard extends HookWidget {
  const _ColorCard({
    Key? key,
    required this.duration,
    this.colors = Colors.primaries,
  }) : super(key: key);

  final Duration duration;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    Color randomColor() => colors.elementAt(_random.nextInt(colors.length));

    final color = useState(randomColor());

    useEffect(() {
      final timer = Timer.periodic(duration, (timer) {
        color.value = randomColor();
      });

      return timer.cancel;
    }, const []);

    return GridCard(
      child: AnimatedContainer(
        duration: kThemeAnimationDuration * 5,
        curve: Curves.ease,
        color: color.value,
      ),
    );
  }
}
