import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/summary/bloc.dart';
import 'package:flutterhole/bloc/top_items/bloc.dart';
import 'package:flutterhole/model/top_items.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/service/routes.dart';
import 'package:flutterhole/widget/home/frequency_tile.dart';
import 'package:flutterhole/widget/layout/error_message.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class TopDomainsBuilder extends StatefulWidget {
  @override
  _TopDomainsBuilderState createState() => _TopDomainsBuilderState();
}

class _TopDomainsBuilderState extends State<TopDomainsBuilder> {
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

    return BlocListener(
        bloc: topItemsBloc,
        listener: (context, state) {
          if (state is TopItemsStateEmpty) {
            topItemsBloc.dispatch(FetchTopItems());
          }

          if (state is TopItemsStateSuccess || state is TopItemsStateError) {
            _refreshCompleter?.complete();
            _refreshCompleter = Completer();

            if (state is TopItemsStateSuccess) {
              setState(() {
                _cache = state.topItems;
              });
            }
          }
        },
        child: RefreshIndicator(
          onRefresh: () {
            topItemsBloc.dispatch(FetchTopItems());
            summaryBloc.dispatch(FetchSummary());
            return _refreshCompleter.future;
          },
          child: BlocBuilder(
            bloc: topItemsBloc,
            builder: (context, state) {
              if (state is TopItemsStateSuccess ||
                  state is TopItemsStateLoading && _cache != null) {
                if (state is TopItemsStateSuccess) {
                  _cache = state.topItems;
                }

                List<Widget> topQueryItems = [];
                _cache.topQueries.forEach((String domain, int frequency) {
                  topQueryItems.add(BlocBuilder(
                    bloc: summaryBloc,
                    builder: (context, state) {
                      int total = 0;
                      if (state is SummaryStateSuccess) {
                        total = state.summary.dnsQueriesToday;
                      }

                      return FrequencyTile(
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

                List<Widget> topAdItems = [];
                _cache.topAds.forEach((String domain, int frequency) {
                  topAdItems.add(BlocBuilder(
                    bloc: summaryBloc,
                    builder: (context, state) {
                      int total = 0;
                      if (state is SummaryStateSuccess) {
                        total = state.summary.adsBlockedToday;
                      }

                      return FrequencyTile(
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

              if (state is TopItemsStateError) {
                return ErrorMessage(errorMessage: state.e.message);
              }

              return Center(child: CircularProgressIndicator());
            },
          ),
        ));
  }
}
