import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole_again/bloc/whitelist/whitelist_bloc.dart';
import 'package:flutterhole_again/bloc/whitelist/whitelist_event.dart';
import 'package:flutterhole_again/bloc/whitelist/whitelist_state.dart';
import 'package:flutterhole_again/widget/error_message.dart';
import 'package:flutterhole_again/widget/removable_tile.dart';

class WhitelistBuilder extends StatefulWidget {
  @override
  _WhitelistBuilderState createState() => _WhitelistBuilderState();
}

class _WhitelistBuilderState extends State<WhitelistBuilder> {
  Completer _refreshCompleter;

  List<String> _cache;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer();
  }

  @override
  Widget build(BuildContext context) {
    final whitelistBloc = BlocProvider.of<WhitelistBloc>(context);
    return BlocListener(
        bloc: whitelistBloc,
        listener: (context, state) {
          if (state is WhitelistStateEmpty) {
            whitelistBloc.dispatch(FetchWhitelist());
          }

          if (state is WhitelistStateSuccess || state is WhitelistStateError) {
            _refreshCompleter?.complete();
            _refreshCompleter = Completer();

            if (state is WhitelistStateSuccess) {
              setState(() {
                _cache = state.cache.list;
              });
            }
          }
        },
        child: RefreshIndicator(
          onRefresh: () {
            whitelistBloc.dispatch(FetchWhitelist());
            return _refreshCompleter.future;
          },
          child: BlocBuilder(
              bloc: whitelistBloc,
              builder: (context, state) {
                if (state is WhitelistStateSuccess ||
                    (state is WhitelistStateLoading &&
                        _cache != null &&
                        _cache.isNotEmpty)) {
                  if (state is WhitelistStateSuccess) {
                    _cache = state.cache.list;
                  }
                  return Scrollbar(
                    child: ListView(
                      children: ListTile.divideTiles(
                          context: context,
                          tiles: _cache.map((String domain) {
                            return RemovableTile(
                              title: domain,
                              onDismissed: (_) {
                                setState(() {
                                  _cache.remove(domain);
                                });
                                whitelistBloc
                                    .dispatch(RemoveFromWhitelist(domain));
                                Scaffold.of(context).showSnackBar(
                                    SnackBar(content: Text("$domain removed")));
                                setState(() {});
                              },
                            );
                          })).toList(),
                    ),
                  );
                }

                if (state is WhitelistStateError) {
                  return Center(
                    child: ListView(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: ErrorMessage(errorMessage: state.errorMessage),
                        ),
                      ],
                    ),
                  );
                }

                return Center(child: CircularProgressIndicator());
              }),
        ));
  }
}
