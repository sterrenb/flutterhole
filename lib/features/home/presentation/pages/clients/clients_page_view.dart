import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/home/blocs/home_bloc.dart';
import 'package:flutterhole/features/home/presentation/widgets/home_bloc_builder.dart';
import 'package:flutterhole/features/home/presentation/widgets/home_page_overflow_refresher.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_client.dart';
import 'package:flutterhole/features/pihole_api/data/models/summary.dart';
import 'package:flutterhole/features/pihole_api/data/models/top_sources.dart';
import 'package:flutterhole/features/pihole_api/presentation/pages/single_client_page.dart';
import 'package:flutterhole/widgets/layout/animations/animated_opener.dart';
import 'package:flutterhole/widgets/layout/indicators/failure_indicators.dart';
import 'package:flutterhole/widgets/layout/indicators/loading_indicators.dart';
import 'package:flutterhole/widgets/layout/lists/frequency_tile.dart';

class ClientsPageView extends StatelessWidget {
  const ClientsPageView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HomeBlocBuilder(builder: (BuildContext context, HomeState state) {
      return state.maybeWhen<Widget>(
          success: (
            Either<Failure, SummaryModel> summaryResult,
            _,
            Either<Failure, TopSourcesResult> topSourcesResult,
            __,
            ___,
            ____,
          ) {
            return topSourcesResult.fold<Widget>(
              (failure) => CenteredFailureIndicator(failure),
              (topSources) {
                final List<PiClient> clients =
                    topSources.topSources.keys.toList();
                final List<int> queryCounts =
                    topSources.topSources.values.toList();

                final int totalQueryCount = summaryResult.fold<int>(
                  (failure) => 1,
                  (summary) => summary.dnsQueriesToday,
                );

                return HomePageOverflowRefresher(
                  child: ListView.builder(
                      itemCount: topSources.topSources.length,
                      itemBuilder: (context, index) {
                        final client = clients.elementAt(index);
                        final queryCount = queryCounts.elementAt(index);

                        return AnimatedOpener(
                          closed: (context) =>
                              FrequencyTile(
                            title: client.nameOrIp,
                            requests: queryCount,
                            totalRequests: totalQueryCount,
                                color: KColors.clients,
                              ),
                          opened: (context) => SingleClientPage(client: client),
                        );
                      }),
                );
              },
            );
          },
          orElse: () => CenteredLoadingIndicator());
    });
  }
}
