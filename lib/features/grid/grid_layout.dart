import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/layout/code_card.dart';
import 'package:flutterhole_web/features/layout/media_queries.dart';

const importGridLayout = null;

class PageGrid extends StatelessWidget {
  const PageGrid({
    Key? key,
    this.pageController,
    this.crossAxisCount = 4,
    required this.tiles,
    required this.children,
    this.padding = const EdgeInsets.all(0),
  })  : assert(tiles.length == children.length),
        super(key: key);

  final ScrollController? pageController;
  final int crossAxisCount;
  final List<StaggeredTile> tiles;
  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return StaggeredGridView.count(
      controller: pageController,
      crossAxisCount: 4,
      mainAxisSpacing: kGridSpacing,
      crossAxisSpacing: kGridSpacing,
      padding: const EdgeInsets.all(kGridSpacing).add(padding),
      physics: const BouncingScrollPhysics(),
      staggeredTiles: tiles,
      children: children,
    );
  }
}

class PortraitPageGrid extends StatelessWidget {
  const PortraitPageGrid({
    Key? key,
    this.pageController,
    required this.tiles,
    required this.children,
  }) : super(key: key);
  final ScrollController? pageController;
  final List<StaggeredTile> tiles;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return PageGrid(
      pageController: pageController,
      tiles: tiles,
      children: children,
      padding: context.clampedBodyPadding,
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

class TileTitle extends StatelessWidget {
  const TileTitle(
    this.title, {
    this.color,
    Key? key,
  }) : super(key: key);

  final String title;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        color: color,
      ),
      textAlign: TextAlign.left,
    );
  }
}

class GridIcon extends StatelessWidget {
  const GridIcon(
    this.primaryIcon, {
    Key? key,
    this.subIcon,
    this.subIconColor,
    this.isDark = false,
    this.size = 32.0,
  }) : super(key: key);

  final IconData primaryIcon;
  final IconData? subIcon;
  final Color? subIconColor;
  final bool isDark;
  final double size;

  @override
  Widget build(BuildContext context) {
    final primary = Icon(
      primaryIcon,
      size: size,
      // color: Theme.of(context).brightness == Brightness.dark
      //     ? Colors.white.withOpacity(0.5)
      //     : Colors.black.withOpacity(0.5),
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
      // color: Colors.white.withOpacity(0.5),
    );

    if (subIcon != null) {
      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          primary,
          Positioned(
              left: 18.0,
              top: 18.0,
              child: Icon(
                subIcon,
                size: 24.0,
                color: subIconColor,
              )),
        ],
      );
    }
    return primary;
  }
}

class GridSectionHeader extends StatelessWidget {
  const GridSectionHeader(
    this.title,
    this.iconData, {
    Key? key,
  }) : super(key: key);

  final String title;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kGridSpacing),
      child: Container(
        // color: Colors.red,
        child: 5 > 6
            ? Center(
                child: ListTile(
                  title: TileTitle(title),
                  leading: GridIcon(iconData),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                        child: GridIcon(iconData),
                      ),
                      TileTitle(title),
                    ],
                  ),
                ],
              ),
      ),
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
        GridSpacer(),
        Expanded(
          child: Card(
            child: right,
          ),
        ),
      ],
    );
  }
}

class CenteredGridTileLoadingIndicator extends StatelessWidget {
  const CenteredGridTileLoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator());
  }
}

class CenteredGridTileErrorIndicator extends StatelessWidget {
  const CenteredGridTileErrorIndicator(
    this.error, {
    Key? key,
    this.stacktrace,
  }) : super(key: key);

  final Object error;
  final StackTrace? stacktrace;

  @override
  Widget build(BuildContext context) {
    return Center(child: ExpandableCode(code: error.toString()));
  }
}

class ResizableGridBody extends HookWidget {
  const ResizableGridBody({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ticker = useSingleTickerProvider();

    return AnimatedSize(
      vsync: ticker,
      duration: kThemeAnimationDuration * 2,
      alignment: Alignment.center,
      curve: Curves.ease,
      child: child,
    );
  }
}
