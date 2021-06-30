import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'refreshable_builder.dart';

class RefreshableGridBuilder extends StatelessWidget {
  const RefreshableGridBuilder({
    Key? key,
    required this.onRefresh,
    required this.tiles,
    required this.children,
    required this.crossAxisCount,
    required this.spacing,
  }) : super(key: key);

  final VoidFutureCallBack onRefresh;
  final List<StaggeredTile> tiles;
  final List<Widget> children;
  final int crossAxisCount;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return RefreshableBuilder(
      onRefresh: onRefresh,
      child: StaggeredGridView.count(
        crossAxisCount: crossAxisCount,
        staggeredTiles: tiles,
        children: children,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        padding: EdgeInsets.all(spacing),
        physics: const BouncingScrollPhysics(),
      ),
    );
  }
}

// class RefreshableGridBuilder extends StatefulWidget {
//   const RefreshableGridBuilder({
//     Key? key,
//     required this.onRefresh,
//     required this.tiles,
//     required this.children,
//     required this.crossAxisCount,
//     required this.spacing,
//   }) : super(key: key);
//
//   final VoidFutureCallBack onRefresh;
//   final List<StaggeredTile> tiles;
//   final List<Widget> children;
//   final int crossAxisCount;
//   final double spacing;
//
//   @override
//   _RefreshableGridBuilderState createState() => _RefreshableGridBuilderState();
// }
//
// class _RefreshableGridBuilderState extends State<RefreshableGridBuilder> {
//   final refreshController = RefreshController();
//
//   @override
//   void dispose() {
//     refreshController.dispose();
//     super.dispose();
//   }
//
//   Future<void> onRefresh() async {
//     try {
//       await widget.onRefresh();
//       refreshController.refreshCompleted();
//     } catch (e) {
//       refreshController.refreshFailed();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return RefreshableBuilder(
//       onRefresh: widget.onRefresh,
//       child: StaggeredGridView.count(
//         crossAxisCount: widget.crossAxisCount,
//         staggeredTiles: widget.tiles,
//         children: widget.children,
//         mainAxisSpacing: widget.spacing,
//         crossAxisSpacing: widget.spacing,
//         padding: EdgeInsets.all(widget.spacing),
//         physics: const BouncingScrollPhysics(),
//       ),
//     );
//   }
// }
