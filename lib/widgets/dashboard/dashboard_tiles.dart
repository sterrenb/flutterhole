import 'package:flutter/material.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/services/api_service.dart';
import 'package:flutterhole/widgets/dashboard/versions_tile.dart';
import 'package:flutterhole/widgets/settings/extensions.dart';
import 'package:flutterhole/widgets/ui/cache.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pihole_api/pihole_api.dart';

import 'dashboard_card.dart';

class DashboardEntryTileBuilder extends StatelessWidget {
  const DashboardEntryTileBuilder({
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
        return const DomainsBlockedTile();
      case DashboardID.versions:
        return const VersionsTile();
      case DashboardID.temperature:
        return const TemperatureTile();
      case DashboardID.memoryUsage:
        return const MemoryUsageTile();

      default:
        return DashboardCard(
          header: DashboardCardHeader(
              title: entry.id.toReadable(), isLoading: false),
          content: const Expanded(child: Center(child: Text('TODO'))),
          // showTitle: entry.constraints.when(
          //   count: (cross, main) => cross > 1 || main > 1,
          //   extent: (cross, extent) => cross > 1,
          //   fit: (cross) => cross > 1,
          // ),
        );
    }
  }
}

class TotalQueriesTile extends HookConsumerWidget {
  const TotalQueriesTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CacheBuilder<PiSummary>(
      provider: activeSummaryProvider,
      builder: (context, summary, isLoading, error) {
        return DashboardFittedTile(
          title: DashboardID.totalQueries.toReadable(),
          text: summary?.dnsQueriesToday.toFormatted(),
          isLoading: isLoading,
          error: error,
          onTap: () {
            ref.refreshSummary();
          },
        );
      },
    );
  }
}

class QueriesBlockedTile extends HookConsumerWidget {
  const QueriesBlockedTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CacheBuilder<PiSummary>(
      provider: activeSummaryProvider,
      builder: (context, summary, isLoading, error) {
        return DashboardFittedTile(
          title: DashboardID.queriesBlocked.toReadable(),
          text: summary?.adsBlockedToday.toFormatted(),
          isLoading: isLoading,
          error: error,
          onTap: () {
            ref.refreshSummary();
          },
        );
      },
    );
  }
}

class PercentBlockedTile extends HookConsumerWidget {
  const PercentBlockedTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CacheBuilder<PiSummary>(
      provider: activeSummaryProvider,
      builder: (context, summary, isLoading, error) {
        return DashboardFittedTile(
          title: DashboardID.percentBlocked.toReadable(),
          text: summary != null
              ? summary.adsPercentageToday.toStringAsFixed(2) + '%'
              : null,
          isLoading: isLoading,
          error: error,
          onTap: () {
            ref.refreshSummary();
          },
        );
      },
    );
  }
}

class DomainsBlockedTile extends HookConsumerWidget {
  const DomainsBlockedTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CacheBuilder<PiSummary>(
      provider: activeSummaryProvider,
      builder: (context, summary, isLoading, error) {
        return DashboardFittedTile(
          title: DashboardID.domainsOnBlocklist.toReadable(),
          text: summary?.domainsBeingBlocked.toFormatted(),
          isLoading: isLoading,
          error: error,
          onTap: () {
            ref.refreshSummary();
          },
        );
      },
    );
  }
}

class TemperatureTile extends HookConsumerWidget {
  const TemperatureTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CacheBuilder<PiDetails>(
      provider: activeDetailsProvider,
      builder: (context, details, isLoading, error) {
        return DashboardFittedTile(
          title: DashboardID.temperature.toReadable(),
          text: details?.temperatureInCelcius,
          isLoading: isLoading,
          error: error,
          onTap: () => ref.refreshDetails(),
        );
      },
    );
  }
}

class MemoryUsageTile extends HookConsumerWidget {
  const MemoryUsageTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CacheBuilder<PiDetails>(
      provider: activeDetailsProvider,
      builder: (context, details, isLoading, error) {
        return DashboardFittedTile(
          title: DashboardID.memoryUsage.toReadable(),
          text: details?.memoryUsage != null
              ? details!.memoryUsage!.toStringAsFixed(2) + '%'
              : null,
          isLoading: isLoading,
          error: error,
          onTap: () => ref.refreshDetails(),
        );
      },
    );
  }
}
