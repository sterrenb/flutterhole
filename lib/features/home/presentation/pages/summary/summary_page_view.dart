import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/home/blocs/home_bloc.dart';
import 'package:flutterhole/features/home/presentation/pages/summary/query_types_tile.dart';
import 'package:flutterhole/features/home/presentation/pages/summary/widgets/forward_destinations_tile.dart';
import 'package:flutterhole/features/home/presentation/pages/summary/widgets/summary_tile.dart';
import 'package:flutterhole/features/home/presentation/widgets/home_bloc_builder.dart';
import 'package:flutterhole/features/home/presentation/widgets/home_bloc_overflow_refresher.dart';
import 'package:flutterhole/features/pihole_api/data/models/dns_query_type.dart';
import 'package:flutterhole/features/pihole_api/data/models/forward_destinations.dart';
import 'package:flutterhole/features/pihole_api/data/models/summary.dart';
import 'package:flutterhole/features/settings/services/preference_service.dart';
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
            Either<Failure, ForwardDestinationsResult>
                forwardDestinationsResult,
            Either<Failure, DnsQueryTypeResult> dnsQueryTypesResult,
          ) {
            return summaryResult.fold<Widget>(
              (failure) => CenteredFailureIndicator(failure),
              (summary) {
                final bool enableTrivia =
                    getIt<PreferenceService>().get(KPrefs.useNumbersApi);

                return HomeBlocOverflowRefresher(
                  child: StaggeredGridView.count(
                    crossAxisCount: 4,
                    children: <Widget>[
                      SummaryTile(
                        title: 'Total Queries',
                        subtitle:
                            '${_numberFormat.format(summary.dnsQueriesToday)}',
                        integer: summary.dnsQueriesToday,
                        color: Colors.green,
                        enableTrivia: enableTrivia,
                      ),
                      SummaryTile(
                        title: 'Queries Blocked',
                        subtitle:
                            '${_numberFormat.format(summary.adsBlockedToday)}',
                        integer: summary.adsBlockedToday,
                        color: Colors.blue,
                        enableTrivia: enableTrivia,
                      ),
                      SummaryTile(
                        title: 'Percent Blocked',
                        subtitle:
                            '${summary.adsPercentageToday.toStringAsFixed(2)}%',
                        integer: summary.adsPercentageToday.round(),
                        color: Colors.orange,
                        enableTrivia: enableTrivia,
                      ),
                      SummaryTile(
                        title: 'Domains on Blocklist',
                        subtitle:
                            '${_numberFormat.format(summary.domainsBeingBlocked)}',
                        color: Colors.red,
                        integer: summary.domainsBeingBlocked,
                        enableTrivia: enableTrivia,
                      ),
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
                    ],
                  ),
                );
              },
            );
          },
          orElse: () => CenteredLoadingIndicator());
    });
  }
}
