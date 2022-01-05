import 'package:flutter/material.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/services/api_service.dart';
import 'package:flutterhole/widgets/layout/animations.dart';
import 'package:flutterhole/widgets/layout/loading_indicator.dart';
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
      default:
        return DashboardCard(
          title: entry.id.toReadable(),
          content: const Expanded(child: Center(child: Text('TODO'))),
          showTitle: entry.constraints.when(
            count: (cross, main) => cross > 1 || main > 1,
            extent: (cross, extent) => cross > 1,
            fit: (cross) => cross > 1,
          ),
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
      builder: (context, summary, isLoading) {
        return DashboardFittedTile(
          title: DashboardID.totalQueries.toReadable(),
          text: summary?.dnsQueriesToday.toFormatted(),
          showLoadingIndicator: isLoading,
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
      builder: (context, summary, isLoading) {
        return DashboardFittedTile(
          title: DashboardID.queriesBlocked.toReadable(),
          text: summary?.adsBlockedToday.toFormatted(),
          showLoadingIndicator: isLoading,
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
      builder: (context, summary, isLoading) {
        return DashboardFittedTile(
          title: DashboardID.percentBlocked.toReadable(),
          text: summary != null
              ? summary.adsPercentageToday.toStringAsFixed(2) + '%'
              : null,
          showLoadingIndicator: isLoading,
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
      builder: (context, summary, isLoading) {
        return DashboardFittedTile(
          title: DashboardID.domainsOnBlocklist.toReadable(),
          text: summary?.domainsBeingBlocked.toFormatted(),
          showLoadingIndicator: isLoading,
          onTap: () {
            ref.refreshSummary();
          },
        );
      },
    );
  }
}

class VersionsTile extends HookConsumerWidget {
  const VersionsTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CacheBuilder<PiVersions>(
      provider: activeVersionsProvider,
      builder: (context, summary, isLoading) {
        return DashboardCard(
          title: DashboardID.versions.toReadable(),
          content: Text('hi'),
        );
        // return DashboardFittedTile(
        //   title: DashboardID.domainsOnBlocklist.toReadable(),
        //   text: summary?.domainsBeingBlocked.toFormatted(),
        //   showLoadingIndicator: isLoading,
        //   onTap: () {
        //     ref.refreshSummary();
        //   },
        // );
      },
    );
  }
}
