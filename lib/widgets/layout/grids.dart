import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

const double kGridSpacing = 4.0;

class PageGrid extends StatelessWidget {
  const PageGrid({
    Key? key,
    this.crossAxisCount = 4,
    required this.children,
  }) : super(key: key);

  final int crossAxisCount;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return StaggeredGrid.count(
      // controller: pageController,
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: kGridSpacing,
      crossAxisSpacing: kGridSpacing,
      // padding: const EdgeInsets.all(kGridSpacing).add(padding),
      // physics: const BouncingScrollPhysics(),
      // staggeredTiles: tiles,
      children: children,
    );
  }
}

class GridInkWell extends StatelessWidget {
  const GridInkWell({
    Key? key,
    required this.child,
    this.onTap,
  }) : super(key: key);

  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kGridSpacing)),
      onTap: onTap,
      child: child,
    );
  }
}

class GridClip extends StatelessWidget {
  const GridClip({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ShapeBorderClipper(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kGridSpacing))),
      child: child,
    );
  }
}

class GridSpacer extends StatelessWidget {
  const GridSpacer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: kGridSpacing);
  }
}

class GridCard extends StatelessWidget {
  const GridCard({
    Key? key,
    required this.child,
    this.color,
  }) : super(key: key);

  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: GridClip(
        child: child,
      ),
    );
  }
}

class DoubleGridCard extends StatelessWidget {
  const DoubleGridCard({
    Key? key,
    required this.left,
    required this.right,
  }) : super(key: key);

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GridCard(
            child: left,
          ),
        ),
        const GridSpacer(),
        Expanded(
          child: Card(
            child: right,
          ),
        ),
      ],
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
