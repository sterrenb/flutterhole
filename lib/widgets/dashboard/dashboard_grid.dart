import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/widgets/layout/responsiveness.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'dashboard_tiles.dart';

class DashboardGrid extends HookConsumerWidget {
  const DashboardGrid({
    Key? key,
    required this.entries,
  }) : super(key: key);

  final List<DashboardEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabledEntries = useMemoized(
      () {
        return entries.where((entry) => entry.enabled).toList();
      },
      [entries],
    );

    if (enabledEntries.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('Select some tiles!'),
        ),
      );
    }

    return BreakpointBuilder(builder: (context, isBig) {
      return StaggeredGrid.count(
        crossAxisCount: isBig ? 8 : 4,
        children: enabledEntries
            .map((entry) => entry.constraints.when(
                  count: (cross, main) => StaggeredGridTile.count(
                      crossAxisCellCount: cross,
                      mainAxisCellCount: main,
                      child: DashboardEntryTileBuilder(entry: entry)),
                  extent: (cross, extent) => StaggeredGridTile.extent(
                      crossAxisCellCount: cross,
                      mainAxisExtent: extent,
                      child: DashboardEntryTileBuilder(entry: entry)),
                  fit: (cross) => StaggeredGridTile.fit(
                      crossAxisCellCount: cross,
                      child: DashboardEntryTileBuilder(entry: entry)),
                ))
            .toList(),
      );
    });
  }
}
