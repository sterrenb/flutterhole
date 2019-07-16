import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole_again/bloc/blacklist/blacklist_bloc.dart';
import 'package:flutterhole_again/bloc/blacklist/blacklist_event.dart';
import 'package:flutterhole_again/bloc/blacklist/blacklist_state.dart';
import 'package:flutterhole_again/model/blacklist.dart';
import 'package:flutterhole_again/service/globals.dart';
import 'package:flutterhole_again/service/routes.dart';
import 'package:flutterhole_again/widget/error_message.dart';
import 'package:flutterhole_again/widget/list_tab.dart';
import 'package:flutterhole_again/widget/removable_tile.dart';

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
      _cache = Blacklist.cloneWithout(_cache, item);
    });
    blacklistBloc.dispatch(RemoveFromBlacklist(item));
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text("${item.entry} removed"),
      action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            blacklistBloc.dispatch(AddToBlacklist(item));
          }),
    ));
  }

  void _edit(BlacklistItem item) async {
    final String message =
        await Globals.router.navigateTo(context, blacklistEditPath(item));
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
          if (state is BlacklistStateEmpty) {
            blacklistBloc.dispatch(FetchBlacklist());
          }

          if (state is BlacklistStateSuccess || state is BlacklistStateError) {
            _refreshCompleter?.complete();
            _refreshCompleter = Completer();

            if (state is BlacklistStateSuccess) {
              setState(() {
                _cache = state.blacklist;
              });
            }
          }
        },
        child: RefreshIndicator(
          onRefresh: () {
            blacklistBloc.dispatch(FetchBlacklist());
            return _refreshCompleter.future;
          },
          child: BlocBuilder(
              bloc: blacklistBloc,
              builder: (context, state) {
                if (state is BlacklistStateSuccess ||
                    (state is BlacklistStateLoading &&
                        _cache != null &&
                        _cache.exact.length + _cache.wildcard.length > 0)) {
                  if (state is BlacklistStateSuccess) {
                    _cache = state.blacklist;
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

                if (state is BlacklistStateError) {
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
