import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/api/summary.dart';
import 'package:flutterhole/bloc/base/event.dart';
import 'package:flutterhole/bloc/base/state.dart';
import 'package:flutterhole/model/summary.dart';
import 'package:flutterhole/widget/home/forward_destinations_chart_builder.dart';
import 'package:flutterhole/widget/home/query_types_chart_builder.dart';
import 'package:flutterhole/widget/layout/error_message.dart';
import 'package:persist_theme/data/models/theme_model.dart';
import 'package:provider/provider.dart';

class SumBuilder extends StatefulWidget {
  @override
  _SumBuilderState createState() => _SumBuilderState();
}

class _SumBuilderState extends State<SumBuilder> {
  Completer _refreshCompleter;

  Summary _cache;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer();
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Provider.of<ThemeModel>(context);
    final SummaryBloc sumBloc = BlocProvider.of<SummaryBloc>(context);
    return BlocListener(
      bloc: sumBloc,
      listener: (context, state) {
        if (state is BlocStateEmpty) {
          sumBloc.dispatch(Fetch());
        }

        if (state is BlocStateSuccess || state is BlocStateError) {
          _refreshCompleter?.complete();
          _refreshCompleter = Completer();

          if (state is BlocStateSuccess) {
            setState(() {
              _cache = state.data;
            });
          }
        }
      },
      child: RefreshIndicator(
          onRefresh: () {
            sumBloc.dispatch(Fetch());
            return _refreshCompleter.future;
          },
          child: SingleChildScrollView(
            child: BlocBuilder(
                bloc: sumBloc,
                builder: (BuildContext context, BlocState state) {
                  if (state is BlocStateSuccess ||
                      state is BlocStateLoading && _cache != null) {
                    if (state is BlocStateSuccess) {
                      _cache = state.data;
                    }

                    final int tint = _theme.darkMode ? 700 : 500;

                    final List<Widget> sumTiles = [
                      SumTile(
                        backgroundColor: Colors.green[tint],
                        title:
                        'Total Queries (${_cache.uniqueClients} clients)',
                        subtitle: numWithCommas(_cache.dnsQueriesToday),
                      ),
                      SumTile(
                        backgroundColor: Colors.lightBlue[tint],
                        title: 'Queries Blocked',
                        subtitle: numWithCommas(_cache.adsBlockedToday),
                      ),
                      SumTile(
                        backgroundColor: Colors.orange[tint],
                        title: 'Percent Blocked',
                        subtitle:
                        '${_cache.adsPercentageToday.toStringAsFixed(1)}%',
                      ),
                      SumTile(
                        backgroundColor: Colors.red[tint],
                        title: 'Domains on Blocklist',
                        subtitle: numWithCommas(_cache.domainsBeingBlocked),
                      ),
                    ];

                    return Column(
//                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ...sumTiles.map((tile) => tile).toList(),
                        QueryTypesChartBuilder(),
                        ForwardDestinationsChartBuilder(),
                      ],
                    );
                  }

                  if (state is BlocStateError) {
                    return ErrorMessage(errorMessage: state.e.message);
                  }

                  return Center(child: CircularProgressIndicator());
                }),
          )),
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
