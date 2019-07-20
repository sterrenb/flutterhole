import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/summary/bloc.dart';
import 'package:flutterhole/model/summary.dart';
import 'package:flutterhole/widget/layout/error_message.dart';
import 'package:persist_theme/data/models/theme_model.dart';
import 'package:provider/provider.dart';

class SummaryBuilder extends StatefulWidget {
  @override
  _SummaryBuilderState createState() => _SummaryBuilderState();
}

class _SummaryBuilderState extends State<SummaryBuilder> {
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
    final SummaryBloc summaryBloc = BlocProvider.of<SummaryBloc>(context);
    return BlocListener(
      bloc: summaryBloc,
      listener: (context, state) {
        if (state is SummaryStateEmpty) {
          summaryBloc.dispatch(FetchSummary());
        }

        if (state is SummaryStateSuccess || state is SummaryStateError) {
          _refreshCompleter?.complete();
          _refreshCompleter = Completer();

          if (state is SummaryStateSuccess) {
            setState(() {
              _cache = state.summary;
            });
          }
        }
      },
      child: Stack(
        children: [
          BlocBuilder(
              bloc: summaryBloc,
              builder: (BuildContext context, SummaryState state) {
                if (state is SummaryStateSuccess ||
                    state is SummaryStateLoading && _cache != null) {
                  if (state is SummaryStateSuccess) {
                    _cache = state.summary;
                  }

                  final int tint = _theme.darkMode ? 700 : 500;

                  final List<Widget> summaryTiles = [
                    SummaryTile(
                      backgroundColor: Colors.green[tint],
                      title: 'Total Queries (${_cache.uniqueClients} clients)',
                      subtitle: numWithCommas(_cache.dnsQueriesToday),
                    ),
                    SummaryTile(
                      backgroundColor: Colors.blue[tint],
                      title: 'Queries Blocked',
                      subtitle: numWithCommas(_cache.adsBlockedToday),
                    ),
                    SummaryTile(
                      backgroundColor: Colors.orange[tint],
                      title: 'Percent Blocked',
                      subtitle:
                      '${_cache.adsPercentageToday.toStringAsFixed(1)}%',
                    ),
                    SummaryTile(
                      backgroundColor: Colors.red[tint],
                      title: 'Domains on Blocklist',
                      subtitle: numWithCommas(_cache.domainsBeingBlocked),
                    ),
                  ];

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: summaryTiles
                        .map((tile) => Expanded(child: tile))
                        .toList(),
                  );
                }

                if (state is SummaryStateError) {
                  return ErrorMessage(errorMessage: state.e.message);
                }

                return Center(child: CircularProgressIndicator());
              }),
          RefreshIndicator(
            onRefresh: () {
              summaryBloc.dispatch(FetchSummary());
              return _refreshCompleter.future;
            },
            child: ListView(
              children: [],
            ),
          ),
        ],
      ),
    );
  }
}

class SummaryTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;

  const SummaryTile({
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
