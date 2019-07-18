import 'package:dio/dio.dart';
import 'package:fimber/fimber.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/blacklist/bloc.dart';
import 'package:flutterhole/bloc/query/bloc.dart';
import 'package:flutterhole/bloc/status/bloc.dart';
import 'package:flutterhole/bloc/summary/bloc.dart';
import 'package:flutterhole/bloc/top_sources/bloc.dart';
import 'package:flutterhole/bloc/whitelist/bloc.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/service/local_storage.dart';
import 'package:flutterhole/service/memory_tree.dart';
import 'package:flutterhole/service/pihole_client.dart';
import 'package:flutterhole/service/routes.dart';
import 'package:flutterhole/widget/app.dart';

void main() async {
  Globals.router = Router();
  Globals.localStorage = await LocalStorage.getInstance();
  configureRoutes(Globals.router);

  Globals.client = PiholeClient(dio: Dio(), localStorage: Globals.localStorage);

  final SummaryBloc summaryBloc =
  SummaryBloc(SummaryRepository(Globals.client));

  final TopSourcesBloc topSourcesBloc =
  TopSourcesBloc(TopSourcesRepository(Globals.client));

  final QueryBloc queryBloc = QueryBloc(QueryRepository(Globals.client));

  final StatusBloc statusBloc = StatusBloc(StatusRepository(Globals.client));

  final WhitelistBloc whitelistBloc =
  WhitelistBloc(WhitelistRepository(Globals.client));

  final BlacklistBloc blacklistBloc =
  BlacklistBloc(BlacklistRepository(Globals.client));

  Globals.refresh = () {
    summaryBloc.dispatch(FetchSummary());
    topSourcesBloc.dispatch(FetchTopSources());
    queryBloc.dispatch(FetchQueries());
    statusBloc.dispatch(FetchStatus());
    whitelistBloc.dispatch(FetchWhitelist());
    blacklistBloc.dispatch(FetchBlacklist());
  };

  assert(() {
    Globals.debug = true;
    return true;
  }());

  Globals.tree = MemoryTree();
  Fimber.plantTree(MemoryTree());

  if (Globals.debug) {
//    BlocSupervisor.delegate = SimpleBlocDelegate();
    Fimber.i('Running in debug mode');
  } else {
    if (Globals.localStorage.cache.isEmpty) {
      await Globals.localStorage.reset();
    }

    Fimber.i('Running in release mode');
  }

  Globals.refresh();

  runApp(App(
    providers: [
      BlocProvider<SummaryBloc>(builder: (context) => summaryBloc),
      BlocProvider<TopSourcesBloc>(builder: (context) => topSourcesBloc),
      BlocProvider<QueryBloc>(builder: (context) => queryBloc),
      BlocProvider<StatusBloc>(builder: (context) => statusBloc),
      BlocProvider<WhitelistBloc>(builder: (context) => whitelistBloc),
      BlocProvider<BlacklistBloc>(builder: (context) => blacklistBloc),
    ],
  ));
}
