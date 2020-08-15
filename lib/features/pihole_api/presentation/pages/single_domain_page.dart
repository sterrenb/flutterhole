import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/features/pihole_api/blocs/single_domain_bloc.dart';
import 'package:flutterhole/features/pihole_api/data/models/query_data.dart';
import 'package:flutterhole/features/pihole_api/presentation/notifiers/string_search_notifier.dart';
import 'package:flutterhole/features/pihole_api/presentation/widgets/list_bloc_listener.dart';
import 'package:flutterhole/features/pihole_api/presentation/widgets/queries_search_app_bar.dart';
import 'package:flutterhole/features/pihole_api/presentation/widgets/queries_search_list_builder.dart';
import 'package:flutterhole/features/pihole_api/presentation/widgets/single_domain_page_overflow_refresher.dart';
import 'package:flutterhole/features/pihole_api/presentation/widgets/single_query_data_tile.dart';
import 'package:flutterhole/features/settings/presentation/widgets/pihole_theme_builder.dart';
import 'package:flutterhole/widgets/layout/indicators/failure_indicators.dart';
import 'package:flutterhole/widgets/layout/indicators/loading_indicators.dart';
import 'package:provider/provider.dart';

class SingleDomainPage extends StatelessWidget {
  const SingleDomainPage({
    Key key,
    @required this.domain,
  }) : super(key: key);

  final String domain;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StringSearchNotifier>(
      create: (BuildContext context) => StringSearchNotifier(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SingleDomainBloc>(
            create: (_) =>
                SingleDomainBloc()..add(SingleDomainEvent.fetchQueries(domain)),
          ),
        ],
        child: PiholeThemeBuilder(
          child: Scaffold(
            appBar: QueriesSearchAppBar(
              title: Text(
                '$domain',
                overflow: TextOverflow.fade,
              ),
            ),
            body: ListBlocListener(
              child: Scrollbar(
                child: BlocBuilder<SingleDomainBloc, SingleDomainState>(
                  builder: (BuildContext context, SingleDomainState state) {
                    return state.maybeWhen(
                      success: (domain, queries) => QueriesSearchListBuilder(
                          initialData: queries,
                          builder: (context, matches) {
                            return SingleDomainPageOverflowRefresher(
                              domain: domain,
                              child: ListView.builder(
                                itemCount: matches.length,
                                itemBuilder: (context, index) {
                                  final QueryData query =
                                      matches.elementAt(index);

                                  return SingleQueryDataTile(query: query);
                                },
                              ),
                            );
                          }),
                      failure: (failure) => CenteredFailureIndicator(failure),
                      orElse: () => CenteredLoadingIndicator(),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
