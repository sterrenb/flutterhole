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
          content: AnimatedCardContent(
              isLoading: isLoading,
              child: destinations == null
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: LayoutBuilder(builder: (context, constraints) {
                          final radius =
                              (constraints.biggest.shortestSide / 2) - 5.0;
                          return ForwardDestinationsPieChart(
                            destinations: destinations,
                            radius: radius > 120.0 ? radius / 2 : radius,
                            centerSpaceRadius:
                                radius > 120.0 ? radius / 2 : 0.0,
                          );
                        }),
                      ),
                    )),
        );
      },
    );
  }
}
