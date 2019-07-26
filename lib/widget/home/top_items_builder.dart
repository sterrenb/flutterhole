import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/api/query.dart';
import 'package:flutterhole/bloc/api/summary.dart';
import 'package:flutterhole/bloc/api/top_items.dart';
import 'package:flutterhole/bloc/base/event.dart';
import 'package:flutterhole/bloc/base/state.dart';
import 'package:flutterhole/model/api/summary.dart';
import 'package:flutterhole/model/api/top_items.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/service/routes.dart';
import 'package:flutterhole/widget/home/frequency_tile.dart';
import 'package:flutterhole/widget/layout/error_message.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class TopItemsBuilder extends StatefulWidget {
  @override
  _TopItemsBuilderState createState() => _TopItemsBuilderState();
}

class _TopItemsBuilderState extends State<TopItemsBuilder> {
  Completer _refreshCompleter;

  TopItems _cache;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer();
  }

  @override
  Widget build(BuildContext context) {
    final TopItemsBloc topItemsBloc = BlocProvider.of<TopItemsBloc>(context);
    final SummaryBloc summaryBloc = BlocProvider.of<SummaryBloc>(context);
    final QueryBloc queryBloc = BlocProvider.of<QueryBloc>(context);

    return BlocListener(
        bloc: topItemsBloc,
        listener: (context, state) {
          if (state is BlocStateEmpty<TopItems>) {
            topItemsBloc.dispatch(Fetch());
          }

          if (state is BlocStateSuccess<TopItems> ||
              state is BlocStateError<TopItems>) {
            _refreshCompleter?.complete();
            _refreshCompleter = Completer();

            if (state is BlocStateSuccess<TopItems>) {
              setState(() {
                _cache = state.data;
              });
            }
          }
        },
        child: RefreshIndicator(
          onRefresh: () {
            topItemsBloc.dispatch(Fetch());
            summaryBloc.dispatch(Fetch());
            return _refreshCompleter.future;
          },
          child: BlocBuilder(
            bloc: topItemsBloc,
            builder: (context, state) {
              if (state is BlocStateSuccess<TopItems> ||
                  state is BlocStateLoading<TopItems> && _cache != null) {
                if (state is BlocStateSuccess<TopItems>) {
                  _cache = state.data;
                }

                List<Widget> topQueryItems = [];
                _cache.topQueries.forEach((String domain, int frequency) {
                  topQueryItems.add(BlocBuilder(
                    bloc: summaryBloc,
                    builder: (context, state) {
                      int total = 0;
                      if (state is BlocStateSuccess<Summary>) {
                        total = state.data.dnsQueriesToday;
                      }

                      return FrequencyTile(
                        title: domain,
                        requests: frequency,
                        totalRequests: total,
                        onTap: () {
                          queryBloc.dispatch(Fetch());
                          Globals.navigateTo(context, querySearchPath(domain));
                        },
                      );
                    },
                  ));
                });

                List<Widget> topAdItems = [];
                _cache.topAds.forEach((String domain, int frequency) {
                  topAdItems.add(BlocBuilder(
                    bloc: summaryBloc,
                    builder: (context, state) {
                      int total = 0;
                      if (state is BlocStateSuccess<Summary>) {
                        total = state.data.adsBlockedToday;
                      }

                      return FrequencyTile(
                        color: Colors.red,
                        title: domain,
                        requests: frequency,
                        totalRequests: total,
                        onTap: () {
                          Globals.navigateTo(context, querySearchPath(domain));
                        },
                      );
                    },
                  ));
                });

                return ListView(
                  children: <Widget>[
                    StickyHeader(
                      header: Container(
                        color: Theme.of(context).secondaryHeaderColor,
                        alignment: Alignment.centerLeft,
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text('Permitted Domain'),
                                  Text('Frequency'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      content: Column(
                        children: ListTile.divideTiles(
                                context: context, tiles: topQueryItems)
                            .toList(),
                      ),
                    ),
                    StickyHeader(
                      header: Container(
                        color: Theme.of(context).secondaryHeaderColor,
                        alignment: Alignment.centerLeft,
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text('Blocked Domain'),
                                  Text('Frequency'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      content: Column(
                        children: ListTile.divideTiles(
                                context: context, tiles: topAdItems)
                            .toList(),
                      ),
                    ),
                  ],
                );
              }

              if (state is BlocStateError<TopItems>) {
                return ListView(
                    children: [ErrorMessage(errorMessage: state.e.message)]);
              }

              return Center(child: CircularProgressIndicator());
            },
          ),
        ));
  }
}
