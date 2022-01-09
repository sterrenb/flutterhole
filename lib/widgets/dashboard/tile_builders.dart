import 'package:flutter/material.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/widgets/dashboard/tiles/summary.dart';
import 'package:flutterhole/widgets/dashboard/versions_tile.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'dashboard_card.dart';
import 'tiles/details.dart';
import 'tiles/forward_destinations.dart';

class DashboardEntryTileBuilder extends StatelessWidget {
  const DashboardEntryTileBuilder({
    Key? key,
    required this.entry,
  }) : super(key: key);

  final DashboardEntry entry;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
        overrides: [
          dashboardEntryProvider.overrideWithValue(entry),
        ],
        child: Builder(
          builder: (context) {
            switch (entry.id) {
              case DashboardID.totalQueries:
                return const TotalQueriesTile();
              case DashboardID.queriesBlocked:
                return const QueriesBlockedTile();
              case DashboardID.percentBlocked:
                return const PercentBlockedTile();
              case DashboardID.domainsOnBlocklist:
                return const DomainsBlockedTile();
              case DashboardID.versions:
                return const VersionsTile();
              case DashboardID.temperature:
                return const TemperatureTile();
              case DashboardID.memoryUsage:
                return const MemoryUsageTile();
              case DashboardID.forwardDestinations:
                return const ForwardDestinationsTile();

              default:
                return DashboardCard(
                  id: entry.id,
                  header: DashboardCardHeader(
                      title: entry.id.humanString, isLoading: false),
                  content: const Expanded(child: Center(child: Text('TODO'))),
                );
            }
          },
        ));
  }
}
