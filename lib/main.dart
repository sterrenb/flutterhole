import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:fimber/fimber.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/blacklist/bloc.dart';
import 'package:flutterhole/bloc/pihole/bloc.dart';
import 'package:flutterhole/bloc/query/bloc.dart';
import 'package:flutterhole/bloc/simple_bloc_delegate.dart';
import 'package:flutterhole/bloc/status/bloc.dart';
import 'package:flutterhole/bloc/summary/bloc.dart';
import 'package:flutterhole/bloc/top_sources/bloc.dart';
import 'package:flutterhole/bloc/versions/bloc.dart';
import 'package:flutterhole/bloc/whitelist/bloc.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/service/local_storage.dart';
import 'package:flutterhole/service/memory_tree.dart';
import 'package:flutterhole/service/pihole_client.dart';
import 'package:flutterhole/service/routes.dart';
import 'package:flutterhole/widget/app.dart';
import 'package:persist_theme/data/models/theme_model.dart';

import 'bloc/forward_destinations/bloc.dart';
import 'bloc/query_types/bloc.dart';
import 'bloc/top_items/bloc.dart';

void main() async {
  Globals.tree = MemoryTree();
  Fimber.plantTree(MemoryTree());

  Globals.router = Router();
  Globals.localStorage = await LocalStorage.getInstance();

  configureRoutes(Globals.router);

  Globals.client = PiholeClient(dio: Dio(), localStorage: Globals.localStorage);

  final PiholeBloc piholeBloc =
  PiholeBloc(PiholeRepository(Globals.localStorage));

  piholeBloc.dispatch(FetchPiholes());

  final SummaryBloc summaryBloc =
  SummaryBloc(SummaryRepository(Globals.client));

  final VersionsBloc versionsBloc =
  VersionsBloc(VersionsRepository(Globals.client));

  final QueryTypesBloc queryTypesBloc =
  QueryTypesBloc(QueryTypesRepository(Globals.client));

  final ForwardDestinationsBloc forwardDestinationsBloc =
  ForwardDestinationsBloc(ForwardDestinationsRepository(Globals.client));

  final TopSourcesBloc topSourcesBloc =
  TopSourcesBloc(TopSourcesRepository(Globals.client));

  final TopItemsBloc topItemsBloc =
  TopItemsBloc(TopItemsRepository(Globals.client));

  final QueryBloc queryBloc = QueryBloc(QueryRepository(Globals.client));

  final StatusBloc statusBloc = StatusBloc(StatusRepository(Globals.client));

  final WhitelistBloc whitelistBloc =
  WhitelistBloc(WhitelistRepository(Globals.client));

  final BlacklistBloc blacklistBloc =
  BlacklistBloc(BlacklistRepository(Globals.client));

  Globals.refreshAllBlocs = () {
    Globals.client.cancel();
    statusBloc.dispatch(FetchStatus());
    summaryBloc.dispatch(FetchSummary());
    versionsBloc.dispatch(FetchVersions());
    queryTypesBloc.dispatch(FetchQueryTypes());
    forwardDestinationsBloc.dispatch(FetchForwardDestinations());
    topSourcesBloc.dispatch(FetchTopSources());
    topItemsBloc.dispatch(FetchTopItems());
    queryBloc.dispatch(FetchQueries());
    whitelistBloc.dispatch(FetchWhitelist());
    blacklistBloc.dispatch(FetchBlacklist());
  };

  assert(() {
    Globals.debug = true;
    return true;
  }());

  if (Globals.debug) {
    BlocSupervisor.delegate = SimpleBlocDelegate();
    Fimber.i('Running in debug mode');
  } else {
    Fimber.i('Running in release mode');
    if (Globals.localStorage.cache.isEmpty) {
      await Globals.localStorage.reset();
      Globals.tree.log('main', 'No configurations found, using default');
    }
  }

  await Globals.localStorage.init();

  print(
      'running app with cache ${Globals.localStorage.cache.length}, ${Globals
          .localStorage
          .active()
          .title}');

  runApp(App(
    themeModel: ThemeModel(),
    providers: [
      BlocProvider<PiholeBloc>(builder: (context) => piholeBloc),
      BlocProvider<SummaryBloc>(builder: (context) => summaryBloc),
      BlocProvider<VersionsBloc>(builder: (context) => versionsBloc),
      BlocProvider<QueryTypesBloc>(builder: (context) => queryTypesBloc),
      BlocProvider<ForwardDestinationsBloc>(
          builder: (context) => forwardDestinationsBloc),
      BlocProvider<TopSourcesBloc>(builder: (context) => topSourcesBloc),
      BlocProvider<TopItemsBloc>(builder: (context) => topItemsBloc),
      BlocProvider<QueryBloc>(builder: (context) => queryBloc),
      BlocProvider<StatusBloc>(builder: (context) => statusBloc),
      BlocProvider<WhitelistBloc>(builder: (context) => whitelistBloc),
      BlocProvider<BlacklistBloc>(builder: (context) => blacklistBloc),
    ],
  ));

  Globals.refreshAllBlocs();
}
