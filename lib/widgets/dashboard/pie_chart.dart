import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pihole_api/pihole_api.dart';

class PieChartRadiusBuilder extends StatelessWidget {
  const PieChartRadiusBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  final ValueWidgetBuilder<double> builder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: LayoutBuilder(builder: (context, constraints) {
          final radius = (constraints.biggest.shortestSide / 2) - 5.0;
          return builder(context, radius, null);
        }),
      ),
    );
  }
}

class ForwardDestinationsPieChart extends HookConsumerWidget {
  const ForwardDestinationsPieChart({
    Key? key,
    required this.destinations,
    this.radius,
    this.touchRadius,
    this.centerSpaceRadius,
  }) : super(key: key);

  final PiForwardDestinations destinations;
  final double? radius;
  final double? touchRadius;
  final double? centerSpaceRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final touchedIndex = useState<int>(-1);
    final sections = useMemoized(() {
      return destinations.destinations.entries
          .toList()
          .asMap()
          .entries
          .map((e) {
        final index = e.key;
        final isTouched = touchedIndex.value == index;
        final percentage = e.value.value;
        final title = e.value.key.split('|').first;

        return PieChartSectionData(
          color: Colors.primaries.reversed
              .elementAt(index % Colors.primaries.length)
              .withOpacity(.75),
          value: percentage,
          title: '',
          badgeWidget: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 100),
                opacity: isTouched ? 0.0 : 1.0,
                child: Text(title),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 100),
                opacity: isTouched ? 1.0 : 0.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title),
                    Text(Formatting.numToPercentage(percentage)),
                  ],
                ),
              ),
            ],
          ),
          titleStyle: Theme.of(context)
              .textTheme
              .subtitle2
              ?.merge(GoogleFonts.firaMono()),
          radius: isTouched
              ? (touchRadius ?? (radius != null ? radius! + 5 : radius))
              : radius,
        );
      }).toList();
    }, [destinations, touchedIndex.value]);
    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(touchCallback:
            (FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
          if (!event.isInterestedForInteractions ||
              pieTouchResponse == null ||
              pieTouchResponse.touchedSection == null) {
            touchedIndex.value = -1;
            return;
          }
          touchedIndex.value =
              pieTouchResponse.touchedSection!.touchedSectionIndex;
        }),
        startDegreeOffset: 270,
        borderData: FlBorderData(
          show: false,
        ),
        sectionsSpace: touchedIndex.value >= 0 ? 4.0 : 1.0,
        centerSpaceRadius: centerSpaceRadius,
        sections: sections,
      ),
      swapAnimationCurve: Curves.easeOutCubic,
    );
  }
}

typedef PieChartTitleBuilder = String Function(String, double, int);
typedef PieChartColorBuilder = Color Function(String, double, int);

class PercentPieChart extends HookConsumerWidget {
  const PercentPieChart({
    Key? key,
    required this.data,
    required this.titleBuilder,
    required this.colorBuilder,
    this.radius,
    this.touchRadius,
    this.centerSpaceRadius,
  }) : super(key: key);

  final Map<String, double> data;
  // final PiForwardDestinations destinations;
  final PieChartTitleBuilder titleBuilder;
  final PieChartColorBuilder colorBuilder;
  final double? radius;
  final double? touchRadius;
  final double? centerSpaceRadius;

  static const double splitRadius = 120.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final touchedIndex = useState<int>(-1);
    final sections = useMemoized(() {
      return data.entries
          .where((element) => element.value > 0)
          .toList()
          .asMap()
          .entries
          .map((e) {
        final index = e.key;
        final isTouched = touchedIndex.value == index;
        final percentage = e.value.value;
        final title = titleBuilder(e.value.key, e.value.value, index);

        return PieChartSectionData(
          color:
              colorBuilder(e.value.key, e.value.value, index).withOpacity(.75),
          value: percentage,
          title: '',
          badgeWidget: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 100),
                opacity: isTouched ? 0.0 : 1.0,
                child: Text(title),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 100),
                opacity: isTouched ? 1.0 : 0.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title),
                    Text(Formatting.numToPercentage(percentage)),
                  ],
                ),
              ),
            ],
          ),
          titleStyle: Theme.of(context)
              .textTheme
              .subtitle2
              ?.merge(GoogleFonts.firaMono()),
          radius: isTouched
              ? (touchRadius ?? (radius != null ? radius! + 5 : radius))
              : radius,
        );
      }).toList();
    }, [data, touchedIndex.value]);
    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(touchCallback:
            (FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
          if (!event.isInterestedForInteractions ||
              pieTouchResponse == null ||
              pieTouchResponse.touchedSection == null) {
            touchedIndex.value = -1;
            return;
          }
          touchedIndex.value =
              pieTouchResponse.touchedSection!.touchedSectionIndex;
        }),
        startDegreeOffset: 270,
        borderData: FlBorderData(
          show: false,
        ),
        sectionsSpace: touchedIndex.value >= 0 ? 4.0 : 1.0,
        centerSpaceRadius: centerSpaceRadius,
        sections: sections,
      ),
      swapAnimationCurve: Curves.easeOutCubic,
    );
  }
}
