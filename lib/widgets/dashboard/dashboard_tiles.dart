import 'package:flutter/material.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/services/api_service.dart';
import 'package:flutterhole/widgets/layout/animations.dart';
import 'package:flutterhole/widgets/layout/loading_indicator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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

typedef SummaryDataCallback<T> = T? Function(PiSummary summary);
typedef SummaryBuilderCallback<T> = Widget Function(
    BuildContext context, T value);

class SummaryCacheBuilder<T> extends HookConsumerWidget {
  const SummaryCacheBuilder({
    Key? key,
    required this.callback,
    required this.builder,
  }) : super(key: key);

  final SummaryDataCallback<T> callback;
  final SummaryBuilderCallback<T?> builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sum = ref.watch(activeSummaryProvider);
    final value = useValueChanged<AsyncValue, T?>(
      sum,
      (_, T? oldResult) {
        final newResult = sum.whenOrNull(data: callback);
        return newResult ?? oldResult;
      },
    );
    return builder(context, value);
  }
}

class TotalQueriesTile extends HookConsumerWidget {
  const TotalQueriesTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sum = ref.watch(activeSummaryProvider);

    return SummaryCacheBuilder<int>(
      callback: (summary) => summary.dnsQueriesToday,
      builder: (context, value) {
        return DashboardFittedTile(
          title: DashboardID.totalQueries.toReadable(),
          text: value?.toFormatted(),
          showLoadingIndicator: sum.isLoading(),
          onTap: () {
            ref.refresh(activeSummaryProvider);
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
    final sum = ref.watch(activeSummaryProvider);

    return SummaryCacheBuilder<int>(
      callback: (summary) => summary.adsBlockedToday,
      builder: (context, value) {
        return DashboardFittedTile(
          title: DashboardID.queriesBlocked.toReadable(),
          text: value?.toFormatted(),
          showLoadingIndicator: sum.isLoading(),
          onTap: () {
            ref.refresh(activeSummaryProvider);
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
    final sum = ref.watch(activeSummaryProvider);

    return SummaryCacheBuilder<double>(
      callback: (summary) => summary.adsPercentageToday,
      builder: (context, value) {
        return DashboardFittedTile(
          // cardColor: Colors.red.shade300,
          // cardColor: Theme.of(context).colorScheme.primary,
          title: DashboardID.percentBlocked.toReadable(),
          text: value != null ? value.toStringAsFixed(2) + '%' : null,
          showLoadingIndicator: sum.isLoading(),
          onTap: () {
            ref.refresh(activeSummaryProvider);
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
    final sum = ref.watch(activeSummaryProvider);

    return SummaryCacheBuilder<int>(
      callback: (summary) => summary.domainsBeingBlocked,
      builder: (context, value) {
        return DashboardFittedTile(
          title: DashboardID.domainsOnBlocklist.toReadable(),
          text: value?.toFormatted(),
          showLoadingIndicator: sum.isLoading(),
          onTap: () {
            ref.refresh(activeSummaryProvider);
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
        // elevation: 5.0,
        color: cardColor,
        child: InkWell(
          onTap: onTap,
          child: SafeArea(
            minimum: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (showTitle) ...[
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              ?.copyWith(color: textColor),
                          maxLines: 3,
                        ),
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
                content,
              ],
            ),
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
      textColor: textColor ?? Theme.of(context).colorScheme.primary,
      cardColor: cardColor,
      showLoadingIndicator: showLoadingIndicator,
      content: FittedText(text: text ?? '-'),
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
    return Expanded(
      child: FittedBox(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
