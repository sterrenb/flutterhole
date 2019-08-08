import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/api/summary.dart';
import 'package:flutterhole/bloc/base/state.dart';
import 'package:flutterhole/service/converter.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/widget/home/chart/forward_destinations_chart_builder.dart';
import 'package:flutterhole/widget/home/chart/query_types_chart_builder.dart';
import 'package:flutterhole/widget/home/clients_over_time_card.dart';
import 'package:flutterhole/widget/home/queries_over_time_card.dart';
import 'package:flutterhole/widget/home/summary_tile.dart';
import 'package:flutterhole/widget/layout/error_message.dart';
import 'package:flutterhole/widget/layout/refreshable.dart';
import 'package:persist_theme/data/models/theme_model.dart';
import 'package:provider/provider.dart';

class SummaryBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _theme = Provider.of<ThemeModel>(context);
    final SummaryBloc summaryBloc = BlocProvider.of<SummaryBloc>(context);
    return Refreshable(
        onRefresh: (context) {
          Globals.fetchForHome(context);
        },
        bloc: summaryBloc,
        child: BlocBuilder(
            bloc: summaryBloc,
            builder: (BuildContext context, BlocState state) {
              if (summaryBloc.hasCache) {
                final _summaryCache = summaryBloc.cache;

                final int tint = _theme.darkMode ? 700 : 500;

                final List<Widget> summaryTiles = [
                  SummaryTile(
                    backgroundColor: Colors.green[tint],
                    title:
                    'Total Queries (${_summaryCache.uniqueClients} clients)',
                    subtitle: numWithCommas(_summaryCache.dnsQueriesToday),
                  ),
                  SummaryTile(
                    backgroundColor: Colors.lightBlue[tint],
                    title: 'Queries Blocked',
                    subtitle: numWithCommas(_summaryCache.adsBlockedToday),
                  ),
                  SummaryTile(
                    backgroundColor: Colors.orange[tint],
                    title: 'Percent Blocked',
                    subtitle:
                    '${_summaryCache.adsPercentageToday.toStringAsFixed(1)}%',
                  ),
                  SummaryTile(
                    backgroundColor: Colors.red[tint],
                    title: 'Domains on Blocklist',
                    subtitle: numWithCommas(_summaryCache.domainsBeingBlocked),
                  ),
                ];

                return ListView(
                  children: [
                    ...summaryTiles,
                    QueriesOverTimeCard(),
                    ClientsOverTimeCard(),
                    QueryTypesChartBuilder(),
                    ForwardDestinationsChartBuilder(),
                  ],
                );
              }

              if (state is BlocStateError) {
                return ErrorMessage(errorMessage: state.e.message);
              }

              return Center(child: CircularProgressIndicator());
            }));
  }
}
