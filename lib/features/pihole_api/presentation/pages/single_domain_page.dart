import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/features/pihole_api/blocs/single_domain_bloc.dart';
import 'package:flutterhole/features/pihole_api/presentation/widgets/many_query_tiles_builder.dart';
import 'package:flutterhole/features/settings/presentation/widgets/pihole_theme_builder.dart';
import 'package:flutterhole/widgets/layout/failure_indicators.dart';
import 'package:flutterhole/widgets/layout/loading_indicators.dart';

class SingleDomainPage extends StatelessWidget {
  const SingleDomainPage({
    Key key,
    @required this.domain,
  }) : super(key: key);

  final String domain;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SingleDomainBloc>(
      create: (_) =>
          SingleDomainBloc()..add(SingleDomainEvent.fetchQueries(domain)),
      child: PiholeThemeBuilder(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              '$domain',
              overflow: TextOverflow.fade,
            ),
          ),
          body: Center(
            child: Builder(
              builder: (context) {
                return BlocBuilder<SingleDomainBloc, SingleDomainState>(
                  builder: (BuildContext context, SingleDomainState state) {
                    return state.maybeWhen(
                      success: (domain, queries) =>
                          ManyQueryTilesBuilder(queries: queries),
                      failure: (failure) => CenteredFailureIndicator(failure),
                      orElse: () => CenteredLoadingIndicator(),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
