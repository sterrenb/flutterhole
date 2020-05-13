import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/home/blocs/home_bloc.dart';
import 'package:flutterhole/features/home/presentation/widgets/home_bloc_builder.dart';
import 'package:flutterhole/features/home/presentation/widgets/home_bloc_overflow_refresher.dart';
import 'package:flutterhole/features/pihole_api/data/models/top_items.dart';
import 'package:flutterhole/features/pihole_api/presentation/pages/single_domain_page.dart';
import 'package:flutterhole/widgets/layout/animated_opener.dart';
import 'package:flutterhole/widgets/layout/failure_indicators.dart';
import 'package:flutterhole/widgets/layout/frequency_tile.dart';
import 'package:flutterhole/widgets/layout/list_with_header.dart';
import 'package:flutterhole/widgets/layout/loading_indicators.dart';
import 'package:supercharged/supercharged.dart';

class DomainsPageView extends StatelessWidget {
  const DomainsPageView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HomeBlocBuilder(
      builder: (BuildContext context, HomeState state) {
        return state.maybeWhen<Widget>(
          success: (
            _,
            __,
            ___,
            Either<Failure, TopItems> topItemsResult,
            ____,
            _____,
          ) {
            return topItemsResult.fold<Widget>(
              (failure) => CenteredFailureIndicator(failure),
              (topItems) {
                return HomeBlocOverflowRefresher(
                  child: CustomScrollView(
                    slivers: <Widget>[
                      TopQueriesListBuilder(topItems),
                      TopAdsListBuilder(topItems),
                    ],
                  ),
                );
              },
            );
          },
          orElse: () => CenteredLoadingIndicator(),
        );
      },
    );
  }
}

class TopQueriesListBuilder extends StatelessWidget {
  const TopQueriesListBuilder(
    this.topItems, {
    Key key,
  }) : super(key: key);

  final TopItems topItems;

  int get _totalQueryCount => topItems.topQueries.values.sum();

  @override
  Widget build(BuildContext context) {
    return ListWithHeader(
      header: ListTile(
        leading: Icon(
          KIcons.success,
          color: KColors.success,
        ),
        title: Text('Top permitted domains'),
      ),
      child: SliverList(
          delegate: SliverChildBuilderDelegate(
        (context, index) {
          final String domain = topItems.topQueries.keys.elementAtOrNull(index);
          final int queryCount =
              topItems.topQueries.values.elementAtOrNull(index);

          return AnimatedOpener(
            closed: (context) =>
                FrequencyTile(
                  title: '$domain',
                  requests: queryCount,
                  totalRequests: _totalQueryCount,
                ),
            opened: (context) => SingleDomainPage(domain: domain),
          );
        },
        childCount: topItems.topQueries.length,
      )),
    );
  }
}

class TopAdsListBuilder extends StatelessWidget {
  const TopAdsListBuilder(this.topItems, {
    Key key,
  }) : super(key: key);

  final TopItems topItems;

  int get _totalQueryCount => topItems.topAds.values.sum();

  @override
  Widget build(BuildContext context) {
    return ListWithHeader(
      header: ListTile(
        leading: Icon(
          KIcons.close,
          color: KColors.error,
        ),
        title: Text('Top blocked domains'),
      ),
      child: SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final String domain = topItems.topAds.keys.elementAtOrNull(index);
              final int queryCount = topItems.topAds.values.elementAtOrNull(
                  index);

              return AnimatedOpener(
                closed: (context) =>
                    FrequencyTile(
                      title: '$domain',
                      requests: queryCount,
                      totalRequests: _totalQueryCount,
                      color: KColors.error,
                    ),
                opened: (context) => SingleDomainPage(domain: domain),
              );
            },
            childCount: topItems.topAds.length,
          )),
    );
  }
}
