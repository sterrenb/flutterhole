import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/api/data/models/pi_client.dart';
import 'package:flutterhole/features/api/data/models/top_sources.dart';
import 'package:flutterhole/features/home/blocs/home_bloc.dart';
import 'package:flutterhole/features/home/presentation/widgets/home_bloc_builder.dart';
import 'package:flutterhole/widgets/layout/failure_indicators.dart';
import 'package:flutterhole/widgets/layout/loading_indicators.dart';

class ClientsPageView extends StatelessWidget {
  const ClientsPageView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HomeBlocBuilder(builder: (BuildContext context, HomeState state) {
      return state.maybeWhen<Widget>(
          success: (
            _,
            __,
            Either<Failure, TopSourcesResult> topSourcesResult,
            ___,
          ) {
            return topSourcesResult.fold<Widget>(
              (failure) => CenteredFailureIndicator(failure),
              (topSources) {
                final List<PiClient> clients = topSources.topSources.keys.toList();
                final  List<int> queryCounts = topSources.topSources.values.toList();
                return ListView.builder(
                  itemCount: topSources.topSources.length,
                  itemBuilder: (context, index) {
                    final client = clients.elementAt(index);
                    final queryCount = queryCounts.elementAt(index);

                    return ListTile(
                      title: Text('${client.title}'),
                    );
                  });
              },
            );
          },
          orElse: () => CenteredLoadingIndicator());
    });
  }
}
