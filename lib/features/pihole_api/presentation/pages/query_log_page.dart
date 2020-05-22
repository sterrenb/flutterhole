import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/pihole_api/blocs/query_log_bloc.dart';
import 'package:flutterhole/features/pihole_api/data/models/query_data.dart';
import 'package:flutterhole/features/pihole_api/presentation/notifiers/queries_search_notifier.dart';
import 'package:flutterhole/features/pihole_api/presentation/widgets/queries_search_app_bar.dart';
import 'package:flutterhole/features/pihole_api/presentation/widgets/queries_search_list_builder.dart';
import 'package:flutterhole/features/pihole_api/presentation/widgets/query_log_page_overflow_refresher.dart';
import 'package:flutterhole/features/pihole_api/presentation/widgets/single_query_data_tile.dart';
import 'package:flutterhole/features/routing/presentation/widgets/default_drawer.dart';
import 'package:flutterhole/features/settings/presentation/widgets/pihole_theme_builder.dart';
import 'package:flutterhole/features/settings/services/preference_service.dart';
import 'package:flutterhole/widgets/layout/indicators/failure_indicators.dart';
import 'package:flutterhole/widgets/layout/indicators/loading_indicators.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

final _numberFormat = NumberFormat();

class _PopupMenu extends StatelessWidget {
  PopupMenuItem<int> _buildPopupMenuItem(int value) {
    return CheckedPopupMenuItem(
      child: Text('${_numberFormat.format(value)}'),
      value: value,
      checked: value == getIt<PreferenceService>().queryLogMaxResults,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      tooltip: 'Set max results',
      onSelected: (int value) async {
        getIt<PreferenceService>().setQueryLogMaxResults(value);

        // Force a delay to allow the PopUpMenu to close.
        // If we don't, the animation hangs until the Bloc returns.
        // TODO not sure what a better solution is, but I assume there is one.
        await Future.delayed(Duration(milliseconds: 300));

        BlocProvider.of<QueryLogBloc>(context)
            .add(QueryLogEvent.fetchSome(value));
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
        PopupMenuItem(
          child: Text('Max results'),
          enabled: false,
        ),
        PopupMenuDivider(),
        _buildPopupMenuItem(10),
        _buildPopupMenuItem(100),
        _buildPopupMenuItem(1000),
        _buildPopupMenuItem(10000),
      ],
    );
  }
}

class QueryLogPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<QueriesSearchNotifier>(
      create: (BuildContext context) => QueriesSearchNotifier(),
      child: BlocProvider<QueryLogBloc>(
        create: (_) => QueryLogBloc()
          ..add(QueryLogEvent.fetchSome(
              getIt<PreferenceService>().queryLogMaxResults)),
        child: PiholeThemeBuilder(
          child: Scaffold(
            drawer: DefaultDrawer(),
            appBar: QueriesSearchAppBar(
              title: Text('Query log'),
              actions: <Widget>[
                _PopupMenu(),
              ],
            ),
            body: Scrollbar(
              child: BlocBuilder<QueryLogBloc, QueryLogState>(
                builder: (BuildContext context, QueryLogState state) {
                  return state.maybeWhen<Widget>(
                    success: (List<QueryData> queries) {
                      return QueriesSearchListBuilder(
                        initialData: queries,
                        builder:
                            (BuildContext context, List<QueryData> matches) {
                          return QueryLogPageOverflowRefresher(
                            child: ListView.builder(
                              itemCount: matches.length,
                              itemBuilder: (context, index) {
                                final QueryData query =
                                    matches.elementAt(index);

                                return SingleQueryDataTile(query: query);
                              },
                            ),
                          );
                        },
                      );
                    },
                    failure: (failure) => CenteredFailureIndicator(failure),
                    initial: () => Container(),
                    orElse: () {
                      return CenteredLoadingIndicator();
                    },
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
