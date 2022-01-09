import 'package:flutter/material.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/services/api_service.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/widgets/dashboard/dashboard_card.dart';
import 'package:flutterhole/widgets/settings/extensions.dart';
import 'package:flutterhole/widgets/ui/cache.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pihole_api/pihole_api.dart';

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
        return DashboardFittedCard(
          id: DashboardID.temperature,
          title: entry.constraints.crossAxisCount > 1
              ? DashboardID.temperature.humanString
              : DashboardID.temperature.humanString.substring(0, 4),
          text: details?.temperatureInCelcius,
          background: const DashboardBackgroundIcon(DashboardID.temperature),
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
        return DashboardFittedCard(
          id: DashboardID.memoryUsage,
          title: DashboardID.memoryUsage.humanString,
          text: details?.memoryUsage != null
              ? details!.memoryUsage!.toStringAsFixed(2) + '%'
              : null,
          background: const DashboardBackgroundIcon(DashboardID.memoryUsage),
          isLoading: isLoading,
          error: error,
          onTap: () => ref.refreshDetails(),
        );
      },
    );
  }
}
