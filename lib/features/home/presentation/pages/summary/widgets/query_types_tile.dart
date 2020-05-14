import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/home/presentation/pages/summary/widgets/graph_legend_item.dart';
import 'package:flutterhole/features/home/presentation/pages/summary/widgets/pie_chart_scaffold.dart';
import 'package:flutterhole/features/home/presentation/pages/summary/widgets/query_types_pie_chart.dart';
import 'package:flutterhole/features/pihole_api/data/models/dns_query_type.dart';
import 'package:flutterhole/widgets/layout/failure_indicators.dart';

class QueryTypesTile extends StatelessWidget {
  const QueryTypesTile(
    this.dnsQueryTypesResult, {
    Key key,
  }) : super(key: key);

  final Either<Failure, DnsQueryTypeResult> dnsQueryTypesResult;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        child: dnsQueryTypesResult.fold<Widget>(
          (failure) => CenteredFailureIndicator(failure),
          (success) => PieChartScaffold(
              title: 'Query types',
              pieChart: QueryTypesPieChart(success.dnsQueryTypes),
              legendItems: success.dnsQueryTypes
                  .asMap()
                  .map<int, Widget>((index, dnsQueryType) => MapEntry(
                        index,
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: GraphLegendItem(
                            index: index,
                            title: dnsQueryType.title,
                            subtitle:
                                '${dnsQueryType.fraction.toStringAsFixed(2)}%',
                            color: QueryTypesPieChart.colorAtIndex(index),
                          ),
                        ),
                      ))
                  .values
                  .toList()),
        ),
      ),
    );
  }
}
