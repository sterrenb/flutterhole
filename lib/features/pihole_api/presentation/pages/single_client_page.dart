import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/features/pihole_api/blocs/single_client_bloc.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_client.dart';
import 'package:flutterhole/features/pihole_api/data/models/query_data.dart';
import 'package:flutterhole/features/pihole_api/presentation/notifiers/queries_search_notifier.dart';
import 'package:flutterhole/features/pihole_api/presentation/widgets/queries_search_app_bar.dart';
import 'package:flutterhole/features/pihole_api/presentation/widgets/queries_search_list_builder.dart';
import 'package:flutterhole/features/pihole_api/presentation/widgets/single_client_page_overflow_refresher.dart';
import 'package:flutterhole/features/pihole_api/presentation/widgets/single_query_data_tile.dart';
import 'package:flutterhole/features/settings/presentation/widgets/pihole_theme_builder.dart';
import 'package:flutterhole/widgets/layout/indicators/failure_indicators.dart';
import 'package:flutterhole/widgets/layout/indicators/loading_indicators.dart';
import 'package:provider/provider.dart';

class SingleClientPage extends StatelessWidget {
  const SingleClientPage({
    Key key,
    @required this.client,
  }) : super(key: key);

  final PiClient client;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<QueriesSearchNotifier>(
      create: (BuildContext context) => QueriesSearchNotifier(),
      child: BlocProvider<SingleClientBloc>(
        create: (_) =>
            SingleClientBloc()..add(SingleClientEvent.fetchQueries(client)),
        child: PiholeThemeBuilder(
          child: Scaffold(
            appBar: QueriesSearchAppBar(
              title: Text('${client.titleOrIp}'),
            ),
            body: Scrollbar(
              child: BlocBuilder<SingleClientBloc, SingleClientState>(
                builder: (BuildContext context, SingleClientState state) {
                  return state.maybeWhen(
                    success: (client, queries) => QueriesSearchListBuilder(
                        initialData: queries,
                        builder: (context, matches) {
                          return SingleClientPageOverflowRefresher(
                            client: client,
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
    );
  }
}
