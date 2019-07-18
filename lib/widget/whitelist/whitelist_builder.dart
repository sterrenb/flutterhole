import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/whitelist/bloc.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/service/routes.dart';
import 'package:flutterhole/widget/layout/error_message.dart';
import 'package:flutterhole/widget/layout/removable_tile.dart';

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

  void _removeDomain(String domain, WhitelistBloc whitelistBloc,
      BuildContext context) {
    setState(() {
      _cache.remove(domain);
    });
    whitelistBloc.dispatch(RemoveFromWhitelist(domain));
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text("$domain removed"),
      action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            whitelistBloc.dispatch(AddToWhitelist(domain));
          }),
    ));
//    setState(() {});
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
                _cache = state.whitelist.list;
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
                    _cache = state.whitelist.list;
                  }
                  return Scrollbar(
                    child: ListView(
                      children: ListTile.divideTiles(
                          context: context,
                          tiles: _cache.map((String domain) {
                            return RemovableTile(
                              title: domain,
                              onTap: () async {
                                final String message = await Globals.navigateTo(
                                  context, whitelistEditPath(domain),
                                );
                                if (message != null)
                                  Scaffold.of(context).showSnackBar(
                                      SnackBar(content: Text(message)));
                              },
                              onDismissed: (_) {
                                _removeDomain(domain, whitelistBloc, context);
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
                          child: ErrorMessage(errorMessage: state.e.message),
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
