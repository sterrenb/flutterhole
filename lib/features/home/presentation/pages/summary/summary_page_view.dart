import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/api/data/models/dns_query_type.dart';
import 'package:flutterhole/features/api/data/models/summary.dart';
import 'package:flutterhole/features/home/blocs/home_bloc.dart';
import 'package:flutterhole/features/home/presentation/pages/summary/query_types_tile.dart';
import 'package:flutterhole/features/home/presentation/pages/summary/widgets/summary_tile.dart';
import 'package:flutterhole/features/home/presentation/widgets/home_bloc_builder.dart';
import 'package:flutterhole/widgets/layout/failure_indicators.dart';
import 'package:flutterhole/widgets/layout/loading_indicators.dart';
import 'package:intl/intl.dart';

final _numberFormat = NumberFormat();

class SummaryPageView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HomeBlocBuilder(builder: (BuildContext context, HomeState state) {
      return state.maybeWhen<Widget>(
          failure: (failure) => CenteredFailureIndicator(failure),
          success: (
            Either<Failure, SummaryModel> summaryResult,
            _,
            __,
            ___,
            Either<Failure, DnsQueryTypeResult> dnsQueryTypesResult,
          ) {
            return summaryResult.fold<Widget>(
              (failure) => CenteredFailureIndicator(failure),
              (summary) => StaggeredGridView.count(
                crossAxisCount: 4,
                children: <Widget>[
                  SummaryTile(
                    title: 'Total Queries',
                    subtitle:
                        '${_numberFormat.format(summary.dnsQueriesToday)}',
                    color: Colors.green,
                  ),
                  SummaryTile(
                    title: 'Queries Blocked',
                    subtitle:
                        '${_numberFormat.format(summary.adsBlockedToday)}',
                    color: Colors.blue,
                  ),
                  SummaryTile(
                    title: 'Percent Blocked',
                    subtitle:
                        '${summary.adsPercentageToday.toStringAsFixed(2)}%',
                    color: Colors.orange,
                  ),
                  SummaryTile(
                    title: 'Domains on Blocklist',
                    subtitle:
                        '${_numberFormat.format(summary.domainsBeingBlocked)}',
                    color: Colors.red,
                  ),
                  QueryTypesTile(dnsQueryTypesResult),
                ],
                staggeredTiles: <StaggeredTile>[
                  StaggeredTile.count(4, 1),
                  StaggeredTile.count(4, 1),
                  StaggeredTile.count(4, 1),
                  StaggeredTile.count(4, 1),
                  StaggeredTile.count(4, 3),
                  StaggeredTile.count(4, 2),
                ],
              ),
            );
          },
          orElse: () => CenteredLoadingIndicator());
    });
  }
}
