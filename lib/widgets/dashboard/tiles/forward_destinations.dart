import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
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

  // static const colors = Colors.primaries;
  // static const colors = [
  //   Colors.orange,
  //   Colors.blueGrey,
  //   Colors.deepPurple,
  //   Colors.green,
  //   Colors.deepOrange,
  //   Colors.lime,
  //   Colors.brown,
  //   Colors.lightGreen,
  //   Colors.pink,
  //   Colors.purple,
  //   Colors.indigo,
  //   Colors.blue,
  //   Colors.lightBlue,
  //   Colors.cyan,
  //   Colors.teal,
  //   Colors.yellow,
  //   Colors.amber,
  // ];
  // static const colors = [
  //   Color(0xffffdb00),
  //   Color(0xffffab0a),
  //   Color(0xffff7c2b),
  //   Color(0xfff04d41),
  //   Color(0xffd11c52),
  //   Color(0xffa8005d),
  //   Color(0xff760061),
  //   Color(0xff3c005c),
  // ];

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
                : PieChartRadiusBuilder(
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
            loadingIndicator: const DashboardBackgroundIcon(KIcons.host),
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

// static const colors = [
  //   Color(0xffffa600),
  //   Color(0xff003f5c),
  //   Color(0xffff7c43),
  //   Color(0xff2f4b7c),
  //   Color(0xfff95d6a),
  //   Color(0xff665191),
  //   Color(0xffd45087),
  //   Color(0xffa05195),
  // ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CacheBuilder<PiQueryTypes>(
      provider: activeQueryTypesProvider,
      builder: (context, queryTypes, isLoading, error) {
        return DashboardCard(
          id: DashboardID.queryTypes,
          header: DashboardCardHeader(
            title: DashboardID.queryTypes.humanString,
            isLoading: isLoading,
            error: error,
          ),
          onTap: () => ref.refreshQueryTypes(),
          content: AnimatedCardContent(
            isLoading: isLoading,
            child: queryTypes == null
                ? Container()
                : PieChartRadiusBuilder(
                    builder: (context, radius, _) => PercentPieChart(
                          data: queryTypes.types,
                          titleBuilder: (title, value, index) =>
                              title.split('|').first,
                          colorBuilder: (title, value, index) =>
                              _colors.elementAt((index + 2) % _colors.length),
                          radius: radius > PercentPieChart.splitRadius
                              ? radius / 2
                              : radius,
                          centerSpaceRadius:
                              radius > PercentPieChart.splitRadius
                                  ? radius / 2
                                  : 0.0,
                        )),
            loadingIndicator: const DashboardBackgroundIcon(KIcons.queryTypes),
          ),
        );
      },
    );
  }
}
