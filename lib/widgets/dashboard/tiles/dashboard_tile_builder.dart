import 'package:flutter/material.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/widgets/dashboard/dashboard_card.dart';
import 'package:flutterhole/widgets/dashboard/tiles/queries_over_time.dart';
import 'package:flutterhole/widgets/dashboard/tiles/summary.dart';
import 'package:flutterhole/widgets/dashboard/tiles/versions_tile.dart';
import 'package:flutterhole/widgets/layout/animations.dart';
import 'package:flutterhole/widgets/settings/extensions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'details.dart';
import 'forward_destinations.dart';

class DashboardTileBuilder extends HookConsumerWidget {
  const DashboardTileBuilder({
    Key? key,
    required this.entry,
  }) : super(key: key);

  final DashboardEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        dashboardEntryProvider.overrideWithValue(entry),
      ],
      child: _Draggable(
        child: _TileBuilder(entry: entry),
      ),
    );
  }
}

class _Draggable extends HookConsumerWidget {
  const _Draggable({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(dashboardEntryProvider);
    final isDragging = useState(false);

    return LayoutBuilder(builder: (context, constraints) {
      return DragTarget<DashboardEntry>(
        onAccept: (newEntry) {
          ref.swapDashboardEntries(entry, newEntry);
        },
        builder: (
          context,
          candidateItems,
          rejectedItems,
        ) {
          return LongPressDraggable<DashboardEntry>(
            data: entry,
            onDragStarted: () {
              isDragging.value = true;
            },
            onDragEnd: (_) => isDragging.value = false,
            onDragCompleted: () => isDragging.value = false,
            onDraggableCanceled: (_, __) => isDragging.value = false,
            feedback: Opacity(
              opacity: .8,
              child: Card(
                child: SizedBox(
                    width: constraints.biggest.width,
                    height: constraints.hasBoundedHeight
                        ? constraints.biggest.height
                        : 200.0,
                    child: Center(child: DashboardBackgroundIcon(entry.id))),
              ),
            ),
            child: DefaultAnimatedOpacity(
              show: !isDragging.value,
              hideOpacity: .5,
              child: child,
            ),
          );
        },
      );
    });
  }
}

class _TileBuilder extends StatelessWidget {
  const _TileBuilder({
    Key? key,
    required this.entry,
  }) : super(key: key);

  final DashboardEntry entry;

  @override
  Widget build(BuildContext context) {
    switch (entry.id) {
      case DashboardID.totalQueries:
        return const TotalQueriesTile();
      case DashboardID.queriesBlocked:
        return const QueriesBlockedTile();
      case DashboardID.percentBlocked:
        return const PercentBlockedTile();
      case DashboardID.domainsOnBlocklist:
        return const DomainsOnBlocklistTile();
      case DashboardID.versions:
        return const VersionsTile();
      case DashboardID.temperature:
        return const TemperatureTile();
      case DashboardID.memoryUsage:
        return const MemoryUsageTile();
      case DashboardID.forwardDestinations:
        return const ForwardDestinationsTile();
      case DashboardID.queryTypes:
        return const QueryTypesTile();
      case DashboardID.queriesOverTime:
        return const QueriesOverTimeTile();

      default:
        return DashboardCard(
          id: entry.id,
          header: DashboardCardHeader(
              title: entry.id.humanString, isLoading: false),
          content: const Expanded(child: Center(child: Text('Coming soon!'))),
          background: DashboardBackgroundIcon(entry.id),
        );
    }
  }
}
