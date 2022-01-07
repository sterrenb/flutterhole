import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/services/api_service.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/widgets/dashboard/pie_chart.dart';
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

class TotalQueriesTile extends HookConsumerWidget {
  const TotalQueriesTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CacheBuilder<PiSummary>(
      provider: activeSummaryProvider,
      builder: (context, summary, isLoading, error) {
        return DashboardFittedTile(
          id: DashboardID.totalQueries,
          title: DashboardID.totalQueries.humanString,
          text: summary?.dnsQueriesToday.toFormatted(),
          background: const DashboardBackgroundIcon(KIcons.totalQueries),
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
          id: DashboardID.queriesBlocked,
          title: DashboardID.queriesBlocked.humanString,
          text: summary?.adsBlockedToday.toFormatted(),
          background: const DashboardBackgroundIcon(KIcons.queriesBlocked),
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
          id: DashboardID.percentBlocked,
          title: DashboardID.percentBlocked.humanString,
          text: summary != null
              ? summary.adsPercentageToday.toStringAsFixed(2) + '%'
              : null,
          background: const DashboardBackgroundIcon(KIcons.percentBlocked),
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
          id: DashboardID.domainsOnBlocklist,
          title: DashboardID.domainsOnBlocklist.humanString,
          text: summary?.domainsBeingBlocked.toFormatted(),
          background: const DashboardBackgroundIcon(KIcons.domainsOnBlocklist),
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
    final entry = ref.watch(dashboardEntryProvider);
    return CacheBuilder<PiDetails>(
      provider: activeDetailsProvider,
      builder: (context, details, isLoading, error) {
        return DashboardFittedTile(
          id: DashboardID.temperature,
          title: entry.constraints.crossAxisCount > 1
              ? DashboardID.temperature.humanString
              : DashboardID.temperature.humanString.substring(0, 4),
          text: details?.temperatureInCelcius,
          background: const DashboardBackgroundIcon(KIcons.temperature),
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
          id: DashboardID.memoryUsage,
          title: DashboardID.memoryUsage.humanString,
          text: details?.memoryUsage != null
              ? details!.memoryUsage!.toStringAsFixed(2) + '%'
              : null,
          background: const DashboardBackgroundIcon(KIcons.memoryUsage),
          isLoading: isLoading,
          error: error,
          onTap: () => ref.refreshDetails(),
        );
      },
    );
  }
}

class ForwardDestinationsTile extends HookConsumerWidget {
  const ForwardDestinationsTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CacheBuilder<PiForwardDestinations>(
      provider: activeForwardDestinationsProvider,
      builder: (context, destinations, isLoading, error) {
        return DashboardCard(
          id: DashboardID.forwardDestinations,
          header: DashboardCardHeader(
            title: DashboardID.forwardDestinations.humanString,
            isLoading: isLoading,
            error: error,
          ),
          onTap: () => ref.refreshForwardDestinations(),
          content: destinations != null
              ? Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: LayoutBuilder(builder: (context, constraints) {
                        final radius =
                            (constraints.biggest.shortestSide / 2) - 5.0;
                        return ForwardDestinationsPieChart(
                          destinations: destinations,
                          radius: radius > 150.0 ? radius / 2 : radius,
                          centerSpaceRadius: radius > 150.0 ? radius / 2 : 0.0,
                        );
                      }),
                    ),
                  ),
                )
              : Container(),
        );
      },
    );
  }
}
