import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/api/whitelist.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/whitelist.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/service/routes.dart';
import 'package:flutterhole/widget/layout/error_message.dart';
import 'package:flutterhole/widget/layout/refreshable.dart';
import 'package:flutterhole/widget/layout/removable_tile.dart';

class WhitelistBuilder extends StatefulWidget {
  @override
  _WhitelistBuilderState createState() => _WhitelistBuilderState();
}

class _WhitelistBuilderState extends State<WhitelistBuilder> {
  Whitelist _cache;

  void _removeDomain(String domain, WhitelistBloc whitelistBloc,
      BuildContext context) {
    setState(() {
      _cache = Whitelist.withoutItem(_cache, domain);
    });
    whitelistBloc.dispatch(Remove(domain));
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text("$domain removed"),
      action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              Globals.client.cancel();
              _cache = Whitelist.withItem(_cache, domain);
            });
            whitelistBloc.dispatch(Add(domain));
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
          if (state is BlocStateSuccess<Whitelist>) {
            setState(() {
              _cache = state.data;
            });
          }
        },
        child: Refreshable(
            onRefresh: (context) {
              Globals.fetchForWhitelistView(context);
            },
            bloc: whitelistBloc,
            child: BlocBuilder(
                bloc: whitelistBloc,
                builder: (context, state) {
                  if (state is BlocStateSuccess<Whitelist> ||
                      (state is BlocStateLoading<Whitelist> &&
                          _cache != null &&
                          _cache.list.isNotEmpty)) {
                    return Scrollbar(
                      child: ListView(
                        children: ListTile.divideTiles(
                            context: context,
                            tiles: _cache.list.map((String domain) {
                              return RemovableTile(
                                title: domain,
                                onTap: () async {
                                  final String message =
                                  await Globals.navigateTo(
                                    context,
                                    whitelistEditPath(domain),
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

                  if (state is BlocStateError<Whitelist>) {
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
                })));
  }
}
