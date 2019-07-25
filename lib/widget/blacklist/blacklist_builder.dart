import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/api/blacklist/bloc.dart';
import 'package:flutterhole/bloc/base/event.dart';
import 'package:flutterhole/bloc/base/state.dart';
import 'package:flutterhole/model/blacklist.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/service/routes.dart';
import 'package:flutterhole/widget/layout/error_message.dart';
import 'package:flutterhole/widget/layout/list_tab.dart';
import 'package:flutterhole/widget/layout/removable_tile.dart';

class BlacklistBuilder extends StatefulWidget {
  @override
  _BlacklistBuilderState createState() => _BlacklistBuilderState();
}

class _BlacklistBuilderState extends State<BlacklistBuilder> {
  Completer _refreshCompleter;

  Blacklist _cache;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer();
  }

  Widget _itemToTile(BlacklistItem item, BlacklistBloc blacklistBloc) =>
      RemovableTile(
        title: item.entry,
        onTap: () => _edit(item),
        onDismissed: (_) {
          _removeItem(item, blacklistBloc, context);
        },
      );

  void _removeItem(
      BlacklistItem item, BlacklistBloc blacklistBloc, BuildContext context) {
    setState(() {
      _cache = Blacklist.withoutItem(_cache, item);
    });
    blacklistBloc.dispatch(Remove(item));
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text("${item.entry} removed"),
      action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            blacklistBloc.dispatch(Add(item));
          }),
    ));
  }

  void _edit(BlacklistItem item) async {
    final String message = await Globals.navigateTo(
      context,
      blacklistEditPath(item),
    );
    if (message != null) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final blacklistBloc = BlocProvider.of<BlacklistBloc>(context);
    return BlocListener(
        bloc: blacklistBloc,
        listener: (context, state) {
          if (state is BlocStateEmpty<Blacklist>) {
            blacklistBloc.dispatch(Fetch());
          }

          if (state is BlocStateSuccess<Blacklist> ||
              state is BlocStateError<Blacklist>) {
            _refreshCompleter?.complete();
            _refreshCompleter = Completer();

            if (state is BlocStateSuccess<Blacklist>) {
              setState(() {
                _cache = state.data;
              });
            }
          }
        },
        child: RefreshIndicator(
          onRefresh: () {
            blacklistBloc.dispatch(Fetch());
            return _refreshCompleter.future;
          },
          child: BlocBuilder(
              bloc: blacklistBloc,
              builder: (context, state) {
                if (state is BlocStateSuccess<Blacklist> ||
                    (state is BlocStateLoading<Blacklist> &&
                        _cache != null &&
                        _cache.exact.length + _cache.wildcard.length > 0)) {
                  if (state is BlocStateSuccess<Blacklist>) {
                    _cache = state.data;
                  }

                  List<Widget> exactTiles = [ListTab('Exact blocking')];
                  exactTiles.addAll(_cache.exact.map((BlacklistItem item) =>
                      _itemToTile(item, blacklistBloc)));

                  List<Widget> wildTiles = [
                    ListTab('Regex & Wildcard blocking')
                  ];
                  wildTiles.addAll(_cache.wildcard.map((BlacklistItem item) =>
                      _itemToTile(item, blacklistBloc)));

                  return Scrollbar(
                    child: ListView(
                      children: ListTile.divideTiles(
                              context: context,
                              tiles: exactTiles..addAll(wildTiles))
                          .toList(),
                    ),
                  );
                }

                if (state is BlocStateError<Blacklist>) {
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
