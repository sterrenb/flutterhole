import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/query/bloc.dart';
import 'package:flutterhole/bloc/summary/bloc.dart';
import 'package:flutterhole/bloc/top_sources/bloc.dart';
import 'package:flutterhole/model/summary.dart';
import 'package:flutterhole/model/top_sources.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/service/routes.dart';
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
          summaryBloc.dispatch(FetchSummary());
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
                    items.add(ListTile(
                      onTap: () {
                        queryBloc
                            .dispatch(FetchQueriesForClient(item.ipString));
                        Globals.navigateTo(context, clientLogPath(title));
                      },
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(title),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    numWithCommas(item.requests),
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .subtitle,
                                  ),
//                                  Text(numWithCommas(item.requests)),
                                ],
                              ),
                              BlocBuilder(
                                bloc: summaryBloc,
                                builder: (context, state) {
                                  double fraction;

                                  if (state is SummaryStateSuccess) {
                                    fraction = item.requests /
                                        state.summary.dnsQueriesToday;

                                    final Widget _percentageText = Text(
                                      '${(fraction * 100).toStringAsFixed(1)}%',
                                      style:
                                      Theme
                                          .of(context)
                                          .textTheme
                                          .caption,
                                    );

                                    return Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2.0),
                                          child: PercentageBox(
                                            width: 100,
                                            fraction: fraction,
                                          ),
                                        ),
                                        _percentageText,
                                      ],
                                    );
                                  }

                                  return Container();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
//                      subtitle: Text(item.ipString),
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
                                Text('Requests sent'),
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

class PercentageBox extends StatelessWidget {
  final double width;
  final double fraction;

  const PercentageBox({Key key, @required this.width, @required this.fraction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.centerStart,
      children: <Widget>[
        ColoredBox(width: fraction * width, color: Colors.green),
        ColoredBox(width: width, color: Theme
            .of(context)
            .dividerColor),
      ],
    );
  }
}

class ColoredBox extends StatelessWidget {
  final double width;
  final Color color;

  const ColoredBox({
    Key key,
    @required this.width,
    @required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 2,
      child: DecoratedBox(decoration: BoxDecoration(color: color)),
    );
  }
}
