import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/api/forward_destinations.dart';
import 'package:flutterhole/bloc/api/queries_over_time.dart';
import 'package:flutterhole/bloc/api/query_types.dart';
import 'package:flutterhole/bloc/api/summary.dart';
import 'package:flutterhole/bloc/base/event.dart';
import 'package:flutterhole/bloc/base/state.dart';
import 'package:flutterhole/model/api/summary.dart';
import 'package:flutterhole/service/convert.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/widget/home/chart/forward_destinations_chart_builder.dart';
import 'package:flutterhole/widget/home/chart/query_types_chart_builder.dart';
import 'package:flutterhole/widget/home/queries_over_time_card.dart';
import 'package:flutterhole/widget/layout/error_message.dart';
import 'package:flutterhole/widget/refreshable.dart';
import 'package:persist_theme/data/models/theme_model.dart';
import 'package:provider/provider.dart';

class SummaryBuilder extends StatefulWidget {
  @override
  _SummaryBuilderState createState() => _SummaryBuilderState();
}

class _SummaryBuilderState extends State<SummaryBuilder> {
  Summary _summaryCache;

  @override
  Widget build(BuildContext context) {
    final _theme = Provider.of<ThemeModel>(context);
    final SummaryBloc summaryBloc = BlocProvider.of<SummaryBloc>(context);
    final ForwardDestinationsBloc forwardDestinationsBloc =
    BlocProvider.of<ForwardDestinationsBloc>(context);
    final QueryTypesBloc queryTypesBloc =
    BlocProvider.of<QueryTypesBloc>(context);
    final QueriesOverTimeBloc queriesOverTimeBloc =
    BlocProvider.of<QueriesOverTimeBloc>(context);

    return BlocListener(
      bloc: summaryBloc,
      listener: (context, state) {
        if (state is BlocStateEmpty) {
          summaryBloc.dispatch(Fetch());
          forwardDestinationsBloc.dispatch(Fetch());
          queryTypesBloc.dispatch(Fetch());
          queriesOverTimeBloc.dispatch(Fetch());
        }

        if (state is BlocStateSuccess || state is BlocStateError) {
          if (state is BlocStateSuccess) {
            setState(() {
              _summaryCache = state.data;
            });
          }
        }
      },
      child: Refreshable(
          onRefresh: (context) {
            Globals.fetchForHome(context);
          },
          bloc: summaryBloc,
          child: BlocBuilder(
              bloc: summaryBloc,
              builder: (BuildContext context, BlocState state) {
                if (state is BlocStateSuccess ||
                    state is BlocStateLoading && _summaryCache != null) {
                  if (state is BlocStateSuccess) {
                    _summaryCache = state.data;
                  }

                  final int tint = _theme.darkMode ? 700 : 500;

                  final List<Widget> summaryTiles = [
                    SumTile(
                      backgroundColor: Colors.green[tint],
                      title:
                      'Total Queries (${_summaryCache.uniqueClients} clients)',
                      subtitle: numWithCommas(_summaryCache.dnsQueriesToday),
                    ),
                    SumTile(
                      backgroundColor: Colors.lightBlue[tint],
                      title: 'Queries Blocked',
                      subtitle: numWithCommas(_summaryCache.adsBlockedToday),
                    ),
                    SumTile(
                      backgroundColor: Colors.orange[tint],
                      title: 'Percent Blocked',
                      subtitle:
                      '${_summaryCache.adsPercentageToday.toStringAsFixed(1)}%',
                    ),
                    SumTile(
                      backgroundColor: Colors.red[tint],
                      title: 'Domains on Blocklist',
                      subtitle:
                      numWithCommas(_summaryCache.domainsBeingBlocked),
                    ),
                  ];

                  return ListView(
                    children: [
                      ...summaryTiles,
                      QueriesOverTimeCard(),
                      QueryTypesChartBuilder(),
                      ForwardDestinationsChartBuilder(),
                    ],
                  );
                }

                if (state is BlocStateError) {
                  return ErrorMessage(errorMessage: state.e.message);
                }

                return Center(child: CircularProgressIndicator());
              })),
    );
  }
}

class SumTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;

  const SumTile({
    Key key,
    @required this.title,
    this.subtitle = '',
    @required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: ListTile(
            title: Text(
              title,
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
