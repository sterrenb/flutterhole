import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/home/blocs/home_bloc.dart';
import 'package:flutterhole/features/home/presentation/pages/summary/widgets/forward_destinations_tile.dart';
import 'package:flutterhole/features/home/presentation/pages/summary/widgets/query_types_tile.dart';
import 'package:flutterhole/features/home/presentation/pages/summary/widgets/summary_tile.dart';
import 'package:flutterhole/features/home/presentation/pages/summary/widgets/total_queries_over_day_tile.dart';
import 'package:flutterhole/features/home/presentation/widgets/home_bloc_builder.dart';
import 'package:flutterhole/features/home/presentation/widgets/home_page_overflow_refresher.dart';
import 'package:flutterhole/features/pihole_api/data/models/dns_query_type.dart';
import 'package:flutterhole/features/pihole_api/data/models/forward_destinations.dart';
import 'package:flutterhole/features/pihole_api/data/models/over_time_data.dart';
import 'package:flutterhole/features/pihole_api/data/models/summary.dart';
import 'package:flutterhole/widgets/layout/indicators/failure_indicators.dart';
import 'package:flutterhole/widgets/layout/indicators/loading_indicators.dart';
import 'package:intl/intl.dart';

final _numberFormat = NumberFormat();

class SummaryPageView extends StatelessWidget {
  const SummaryPageView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HomeBlocBuilder(builder: (BuildContext context, HomeState state) {
      return state.maybeWhen<Widget>(
          failure: (failure) => CenteredFailureIndicator(failure),
          success: (
            Either<Failure, SummaryModel> summaryResult,
            Either<Failure, OverTimeData> queriesOverTimeResult,
            _,
            __,
            Either<Failure, ForwardDestinationsResult>
                forwardDestinationsResult,
            Either<Failure, DnsQueryTypeResult> dnsQueryTypesResult,
          ) =>
              summaryResult.fold<Widget>(
                    (failure) => CenteredFailureIndicator(failure),
                    (summary) =>
                    HomePageOverflowRefresher(
                  child: StaggeredGridView.count(
                    crossAxisCount: 4,
                    children: <Widget>[
                      SummaryTile(
                        title: 'Total Queries',
                        subtitle:
                        '${_numberFormat.format(summary.dnsQueriesToday)}',
                        integer: summary.dnsQueriesToday,
                        color: Colors.green,
                      ),
                      SummaryTile(
                        title: 'Queries Blocked',
                        subtitle:
                        '${_numberFormat.format(summary.adsBlockedToday)}',
                        integer: summary.adsBlockedToday,
                        color: Colors.blue,
                      ),
                      SummaryTile(
                        title: 'Percent Blocked',
                        subtitle:
                        '${summary.adsPercentageToday.toStringAsFixed(2)}%',
                        integer: summary.adsPercentageToday.round(),
                        color: Colors.orange,
                      ),
                      SummaryTile(
                        title: 'Domains on Blocklist',
                        subtitle:
                        '${_numberFormat.format(summary.domainsBeingBlocked)}',
                        color: Colors.red,
                        integer: summary.domainsBeingBlocked,
                      ),
                      TotalQueriesOverDayTile(queriesOverTimeResult),
                      QueryTypesTile(dnsQueryTypesResult),
                      ForwardDestinationsTile(forwardDestinationsResult),
                    ],
                    staggeredTiles: <StaggeredTile>[
                      StaggeredTile.count(4, 1),
                      StaggeredTile.count(4, 1),
                      StaggeredTile.count(4, 1),
                      StaggeredTile.count(4, 1),
                      StaggeredTile.count(4, 3),
                      StaggeredTile.count(4, 3),
                      StaggeredTile.count(4, 3),
                    ],
                  ),
                    ),
              ),
          orElse: () => CenteredLoadingIndicator());
    });
  }
}
