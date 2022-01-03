import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DashboardGrid extends HookConsumerWidget {
  const DashboardGrid({
    Key? key,
    required this.entries,
  }) : super(key: key);

  final List<DashboardEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StaggeredGrid.count(
      crossAxisCount: 4,
      children: entries
          .map((entry) => entry.constraints.when(
                count: (cross, main) => StaggeredGridTile.count(
                    crossAxisCellCount: cross,
                    mainAxisCellCount: main,
                    child: EntryTileBuilder(entry: entry)),
                extent: (cross, extent) => StaggeredGridTile.extent(
                    crossAxisCellCount: cross,
                    mainAxisExtent: extent,
                    child: EntryTileBuilder(entry: entry)),
                fit: (cross) => StaggeredGridTile.fit(
                    crossAxisCellCount: cross,
                    child: EntryTileBuilder(entry: entry)),
              ))
          .toList(),
    );
  }
}

class EntryTileBuilder extends StatelessWidget {
  const EntryTileBuilder({
    Key? key,
    required this.entry,
  }) : super(key: key);

  final DashboardEntry entry;

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.primaries
            .elementAt(DashboardID.values.indexOf(entry.id))
            .shade300,
        child: Center(child: Text(entry.id.toReadable())));
  }
}
