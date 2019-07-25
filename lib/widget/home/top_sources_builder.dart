import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/base/event.dart';
import 'package:flutterhole/bloc/base/pihole/summary.dart';
import 'package:flutterhole/bloc/base/state.dart';
import 'package:flutterhole/bloc/query/bloc.dart';
import 'package:flutterhole/bloc/top_sources/bloc.dart';
import 'package:flutterhole/model/summary.dart';
import 'package:flutterhole/model/top_sources.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/service/routes.dart';
import 'package:flutterhole/widget/home/frequency_tile.dart';
import 'package:flutterhole/widget/layout/error_message.dart';
import 'package:sticky_headers/sticky_headers.dart';

class TopSourcesBuilder extends StatefulWidget {
  @override
  _TopSourcesBuilderState createState() => _TopSourcesBuilderState();
}

class _TopSourcesBuilderState extends State<TopSourcesBuilder> {
  Completer _refreshCompleter;

  TopSources _cache;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer();
  }

  @override
  Widget build(BuildContext context) {
    final TopSourcesBloc topSourcesBloc =
        BlocProvider.of<TopSourcesBloc>(context);
    final SummaryBloc summaryBloc = BlocProvider.of<SummaryBloc>(context);
    final QueryBloc queryBloc = BlocProvider.of<QueryBloc>(context);
    return BlocListener(
      bloc: topSourcesBloc,
      listener: (context, state) {
        if (state is TopSourcesStateEmpty) {
          topSourcesBloc.dispatch(FetchTopSources());
        }

        if (state is TopSourcesStateSuccess || state is TopSourcesStateError) {
          _refreshCompleter?.complete();
          _refreshCompleter = Completer();

          if (state is TopSourcesStateSuccess) {
            setState(() {
              _cache = state.topSources;
            });
          }
        }
      },
      child: RefreshIndicator(
        onRefresh: () {
          topSourcesBloc.dispatch(FetchTopSources());
          summaryBloc.dispatch(Fetch());
          return _refreshCompleter.future;
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: BlocBuilder(
              bloc: topSourcesBloc,
              builder: (BuildContext context, TopSourcesState state) {
                if (state is TopSourcesStateSuccess ||
                    state is TopSourcesStateLoading && _cache != null) {
                  if (state is TopSourcesStateSuccess) {
                    _cache = state.topSources;
                  }

                  List<Widget> items = [];

                  _cache.items.forEach((TopSourceItem item) {
                    final String title = item.title.isEmpty
                        ? item.ipString
                        : '${item.ipString} (${item.title})';

                    items.add(BlocBuilder(
                      bloc: summaryBloc,
                      builder: (context, state) {
                        int total = 0;
                        if (state is BlocStateSuccess<Summary>) {
                          total = state.data.dnsQueriesToday;
                        }

                        return FrequencyTile(
                          title: title,
                          requests: item.requests,
                          totalRequests: total,
                          onTap: () {
                            queryBloc
                                .dispatch(FetchQueriesForClient(item.ipString));
                            Globals.navigateTo(
                                context, clientLogPath(item.ipString));
                          },
                        );
                      },
                    ));
                  });

                  return StickyHeader(
                    header: Container(
                      color: Theme
                          .of(context)
                          .secondaryHeaderColor,
                      alignment: Alignment.centerLeft,
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Client'),
                                Text('Frequency'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    content: Column(
                      children:
                      ListTile.divideTiles(context: context, tiles: items)
                          .toList(),
                    ),
                  );
                }

                if (state is TopSourcesStateError) {
                  return ErrorMessage(errorMessage: state.e.message);
                }

                return Center(child: CircularProgressIndicator());
              }),
        ),
      ),
    );
  }
}
