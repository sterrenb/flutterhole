import 'package:flutter/material.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/services/api_service.dart';
import 'package:flutterhole/widgets/dashboard/dashboard_card.dart';
import 'package:flutterhole/widgets/settings/extensions.dart';
import 'package:flutterhole/widgets/ui/cache.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pihole_api/pihole_api.dart';

class TotalQueriesTile extends HookConsumerWidget {
  const TotalQueriesTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CacheBuilder<PiSummary>(
      provider: activeSummaryProvider,
      builder: (context, summary, isLoading, error) {
        return DashboardFittedCard(
          id: DashboardID.totalQueries,
          title: DashboardID.totalQueries.humanString,
          text: summary?.dnsQueriesToday.toFormatted(),
          background: const DashboardBackgroundIcon(DashboardID.totalQueries),
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
        return DashboardFittedCard(
          id: DashboardID.queriesBlocked,
          title: DashboardID.queriesBlocked.humanString,
          text: summary?.adsBlockedToday.toFormatted(),
          background: const DashboardBackgroundIcon(DashboardID.queriesBlocked),
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
        return DashboardFittedCard(
          id: DashboardID.percentBlocked,
          title: DashboardID.percentBlocked.humanString,
          text: summary != null
              ? summary.adsPercentageToday.toStringAsFixed(2) + '%'
              : null,
          background: const DashboardBackgroundIcon(DashboardID.percentBlocked),
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

class DomainsOnBlocklistTile extends HookConsumerWidget {
  const DomainsOnBlocklistTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CacheBuilder<PiSummary>(
      provider: activeSummaryProvider,
      builder: (context, summary, isLoading, error) {
        return DashboardFittedCard(
          id: DashboardID.domainsOnBlocklist,
          title: DashboardID.domainsOnBlocklist.humanString,
          text: summary?.domainsBeingBlocked.toFormatted(),
          background:
              const DashboardBackgroundIcon(DashboardID.domainsOnBlocklist),
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
