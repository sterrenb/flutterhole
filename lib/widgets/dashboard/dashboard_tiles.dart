import 'package:flutter/material.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/services/api_service.dart';
import 'package:flutterhole/widgets/layout/animations.dart';
import 'package:flutterhole/widgets/layout/loading_indicator.dart';
import 'package:flutterhole/widgets/ui/cache.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pihole_api/pihole_api.dart';

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

class DashboardCard extends StatelessWidget {
  const DashboardCard({
    Key? key,
    required this.title,
    required this.content,
    this.showTitle = true,
    this.showLoadingIndicator = false,
    this.onTap,
    this.textColor,
    this.cardColor,
  }) : super(key: key);

  final String title;
  final Widget content;
  final bool showTitle;
  final bool showLoadingIndicator;
  final VoidCallback? onTap;
  final Color? textColor;
  final Color? cardColor;

  @override
  Widget build(BuildContext context) {
    return Card(
        color: cardColor,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (showTitle) ...[
                      Text(
                        title,
                        style: Theme.of(context).textTheme.subtitle1?.copyWith(
                            color: textColor ??
                                Theme.of(context).colorScheme.primary),
                        maxLines: 3,
                      ),
                    ] else ...[
                      Container(),
                    ],
                    AnimatedFader(
                      child: showLoadingIndicator
                          ? LoadingIndicator(
                              size: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  ?.fontSize,
                            )
                          : Container(),
                    ),
                  ],
                ),
              ),
              content,
            ],
          ),
        ));
  }
}

class DashboardFittedTile extends StatelessWidget {
  const DashboardFittedTile({
    Key? key,
    required this.title,
    this.text,
    this.showLoadingIndicator = false,
    this.onTap,
    this.textColor,
    this.cardColor,
  }) : super(key: key);

  final String title;
  final String? text;
  final bool showLoadingIndicator;
  final VoidCallback? onTap;
  final Color? textColor;
  final Color? cardColor;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: title,
      onTap: onTap,
      textColor: textColor,
      cardColor: cardColor,
      showLoadingIndicator: showLoadingIndicator,
      content: Expanded(
          child: Padding(
        padding:
            const EdgeInsets.all(8.0).subtract(const EdgeInsets.only(top: 8.0)),
        child: FittedText(text: text ?? '-'),
      )),
      // content: const Expanded(child: Center(child: Text('TODO'))),
    );
  }
}

class FittedText extends StatelessWidget {
  const FittedText({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
