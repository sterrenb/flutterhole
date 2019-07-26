import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/api/query.dart';
import 'package:flutterhole/bloc/api/summary.dart';
import 'package:flutterhole/bloc/api/top_sources.dart';
import 'package:flutterhole/bloc/base/event.dart';
import 'package:flutterhole/bloc/base/state.dart';
import 'package:flutterhole/model/api/summary.dart';
import 'package:flutterhole/model/api/top_sources.dart';
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
        if (state is BlocStateEmpty<TopSources>) {
          topSourcesBloc.dispatch(Fetch());
        }

        if (state is BlocStateSuccess<TopSources> ||
            state is BlocStateError<TopSources>) {
          _refreshCompleter?.complete();
          _refreshCompleter = Completer();

          if (state is BlocStateSuccess<TopSources>) {
            setState(() {
              _cache = state.data;
            });
          }
        }
      },
      child: RefreshIndicator(
        onRefresh: () {
          topSourcesBloc.dispatch(Fetch());
          summaryBloc.dispatch(Fetch());
          return _refreshCompleter.future;
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: BlocBuilder(
              bloc: topSourcesBloc,
              builder: (BuildContext context, BlocState state) {
                if (state is BlocStateSuccess<TopSources> ||
                    state is BlocStateLoading<TopSources> && _cache != null) {
                  if (state is BlocStateSuccess<TopSources>) {
                    _cache = state.data;
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
                            queryBloc.dispatch(FetchForClient(item.ipString));
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

                if (state is BlocStateError<TopSources>) {
                  return ErrorMessage(errorMessage: state.e.message);
                }

                return Center(child: CircularProgressIndicator());
              }),
        ),
      ),
    );
  }
}
