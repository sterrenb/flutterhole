import 'package:flutter/material.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/services/api_service.dart';
import 'package:flutterhole/widgets/dashboard/dashboard_card.dart';
import 'package:flutterhole/widgets/dashboard/pie_chart.dart';
import 'package:flutterhole/widgets/settings/extensions.dart';
import 'package:flutterhole/widgets/ui/cache.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pihole_api/pihole_api.dart';

final _colors = Colors.primaries.reversed.toList();

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
          // header: DashboardCardHeader(
          //   title: DashboardID.forwardDestinations.humanString,
          //   isLoading: isLoading,
          //   error: error,
          // ),
          onTap: () => ref.refreshForwardDestinations(),
          content: AnimatedCardContent(
            isLoading: isLoading,
            child: destinations == null
                ? Container()
                : Stack(
                    alignment: Alignment.topLeft,
                    children: [
                      DashboardCardHeader(
                        title: DashboardID.forwardDestinations.humanString,
                        isLoading: isLoading,
                        error: error,
                      ),
                      PieChartRadiusBuilder(
                          builder: (context, radius, _) => PercentPieChart(
                                data: destinations.destinations,
                                titleBuilder: (title, value, index) =>
                                    title.split('|').first,
                                colorBuilder: (title, value, index) =>
                                    _colors.elementAt(index % _colors.length),
                                radius: radius > PercentPieChart.splitRadius
                                    ? radius / 2
                                    : radius,
                                centerSpaceRadius:
                                    radius > PercentPieChart.splitRadius
                                        ? radius / 2
                                        : 0.0,
                              )),
                    ],
                  ),
            loadingIndicator:
                const DashboardBackgroundIcon(DashboardID.forwardDestinations),
          ),
        );
      },
    );
  }
}

class QueryTypesTile extends HookConsumerWidget {
  const QueryTypesTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CacheBuilder<PiQueryTypes>(
      provider: activeQueryTypesProvider,
      builder: (context, queryTypes, isLoading, error) {
        return DashboardCard(
          id: DashboardID.queryTypes,
          onTap: () => ref.refreshQueryTypes(),
          content: AnimatedCardContent(
            isLoading: isLoading,
            child: queryTypes == null
                ? Container()
                : Stack(
                    alignment: Alignment.topLeft,
                    children: [
                      DashboardCardHeader(
                        title: DashboardID.queryTypes.humanString,
                        isLoading: isLoading,
                        error: error,
                      ),
                      PieChartRadiusBuilder(
                          builder: (context, radius, _) => PercentPieChart(
                                data: queryTypes.types,
                                titleBuilder: (title, value, index) =>
                                    title.split('|').first,
                                colorBuilder: (title, value, index) => _colors
                                    .elementAt((index + 2) % _colors.length),
                                radius: radius > PercentPieChart.splitRadius
                                    ? radius / 2
                                    : radius,
                                centerSpaceRadius:
                                    radius > PercentPieChart.splitRadius
                                        ? radius / 2
                                        : 0.0,
                              )),
                    ],
                  ),
            loadingIndicator:
                const DashboardBackgroundIcon(DashboardID.queryTypes),
          ),
        );
      },
    );
  }
}
