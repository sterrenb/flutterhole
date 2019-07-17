import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/top_sources/bloc.dart';
import 'package:flutterhole/model/top_sources.dart';
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
                    items.add(ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          item.title.isEmpty
                              ? Text(item.ipString)
                              : Text(item.title),
                          Text(item.requests.toString()),
                        ],
                      ),
                      subtitle: item.title.isEmpty ? null : Text(item.ipString),
                    ));
                  });

                  return StickyHeader(
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
                                  Text('Client'),
                                  Text('Requests sent'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      content: Column(
                        children: items,
                      ));
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
