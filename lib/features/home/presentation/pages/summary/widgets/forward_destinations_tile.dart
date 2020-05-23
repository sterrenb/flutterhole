import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/home/presentation/pages/summary/widgets/forward_destinations_pie_chart.dart';
import 'package:flutterhole/features/home/presentation/pages/summary/widgets/graph_legend_item.dart';
import 'package:flutterhole/features/home/presentation/pages/summary/widgets/pie_chart_scaffold.dart';
import 'package:flutterhole/features/pihole_api/data/models/forward_destinations.dart';
import 'package:flutterhole/widgets/layout/failure_indicators.dart';

class ForwardDestinationsTile extends StatelessWidget {
  const ForwardDestinationsTile(
    this.forwardDestinationsResult, {
    Key key,
  }) : super(key: key);

  final Either<Failure, ForwardDestinationsResult> forwardDestinationsResult;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        child: forwardDestinationsResult.fold<Widget>(
          (failure) => CenteredFailureIndicator(failure),
          (success) => PieChartScaffold(
              title: 'Forward destinations',
              pieChart:
                  ForwardDestinationsPieChart(success.forwardDestinations),
              legendItems: success.forwardDestinations
                  .map<int, Widget>((forwardDestination, percentage) {
                    final int index = success.forwardDestinations.keys
                        .toList()
                        .indexOf(forwardDestination);

                    return MapEntry(
                      index,
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: GraphLegendItem(
                          index: index,
                          title: forwardDestination.titleOrIp,
                          subtitle: '$percentage%',
                          color:
                          ForwardDestinationsPieChart.colorAtIndex(index),
                        ),
                      ),
                    );
                  })
                  .values
                  .toList()),
        ),
      ),
    );
  }
}
