import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/grid/grid_layout.dart';

class SinglePiGrid extends StatelessWidget {
  const SinglePiGrid({
    Key? key,
    required this.pageController,
    required this.tiles,
    required this.children,
  })  : assert(tiles.length == children.length),
        super(key: key);

  final ScrollController pageController;
  final List<StaggeredTile> tiles;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return StaggeredGridView.count(
      controller: pageController,
      crossAxisCount: 4,
      mainAxisSpacing: kGridSpacing,
      crossAxisSpacing: kGridSpacing,
      padding: const EdgeInsets.all(kGridSpacing),
      physics: const BouncingScrollPhysics(),
      staggeredTiles: tiles,
      children: children,
    );
  }
}

class PiGridCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const PiGridCard({
    Key? key,
    required this.child,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).dividerColor, width: 1.0),
        borderRadius: BorderRadius.circular(kGridSpacing),
      ),
      child: GridInkWell(
        onTap: onTap,
        child: child,
      ),
    );
  }
}

class DoublePiGridCard extends StatelessWidget {
  final Widget left;
  final Widget right;
  final VoidCallback? onTap;

  const DoublePiGridCard({
    Key? key,
    required this.left,
    required this.right,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PiGridCard(
      child: GridInkWell(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: left,
            ),
            Expanded(
              child: right,
            ),
          ],
        ),
      ),
    );
  }
}

class TriplePiGridCard extends StatelessWidget {
  final Widget left;
  final Widget right;
  final Widget bottom;
  final VoidCallback? onTap;

  const TriplePiGridCard({
    Key? key,
    required this.left,
    required this.right,
    required this.bottom,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PiGridCard(
      child: GridInkWell(
        onTap: onTap,
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: left,
                  ),
                  Expanded(
                    child: right,
                  ),
                ],
              ),
            ),
            Expanded(
              child: bottom,
            ),
          ],
        ),
      ),
    );
  }
}
