import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pihole_api/pihole_api.dart';

class ForwardDestinationsPieChart extends HookConsumerWidget {
  const ForwardDestinationsPieChart({Key? key, required this.destinations})
      : super(key: key);

  final PiForwardDestinations destinations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final touchedIndex = useState<int>(-1);

    final int? lastTouched =
        useValueChanged<int, int>(touchedIndex.value, (oldValue, _) {
      return math.max(oldValue, touchedIndex.value);
    });

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
              .elementAt(index % Colors.primaries.length),
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
          radius: isTouched ? 82.0 : 80.0,
        );
      }).toList();
    }, [destinations, touchedIndex.value]);
    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
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
            sections: sections,
          ),
          swapAnimationCurve: Curves.easeOutCubic,
        ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 100),
          opacity: touchedIndex.value >= 0 ? 1.0 : 0.0,
          child: Text(
            (lastTouched?.clamp(
                            -1, destinations.destinations.keys.length - 1) ??
                        -1) >=
                    0
                ? Formatting.numToPercentage(
                    destinations.destinations.values.elementAt(lastTouched!))
                : '',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.subtitle2,
          ),
        ),
      ],
    );
  }
}
