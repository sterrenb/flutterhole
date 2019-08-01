import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:fimber/fimber.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/api/blacklist.dart';
import 'package:flutterhole/bloc/api/forward_destinations.dart';
import 'package:flutterhole/bloc/api/queries_over_time.dart';
import 'package:flutterhole/bloc/api/query.dart';
import 'package:flutterhole/bloc/api/query_types.dart';
import 'package:flutterhole/bloc/api/summary.dart';
import 'package:flutterhole/bloc/api/top_items.dart';
import 'package:flutterhole/bloc/api/top_sources.dart';
import 'package:flutterhole/bloc/api/versions.dart';
import 'package:flutterhole/bloc/api/whitelist.dart';
import 'package:flutterhole/bloc/pihole/bloc.dart';
import 'package:flutterhole/bloc/simple_bloc_delegate.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/service/memory_tree.dart';
import 'package:flutterhole/service/pihole_client.dart';
import 'package:flutterhole/service/routes.dart';
import 'package:flutterhole/service/secure_store.dart';
import 'package:flutterhole/widget/app.dart';
import 'package:persist_theme/data/models/theme_model.dart';

import 'bloc/api/status.dart';
import 'bloc/base/event.dart';

void main() async {
  Globals.tree = MemoryTree();
  Fimber.plantTree(MemoryTree());

  Globals.router = Router();
  Globals.secureStore = SecureStore();

  await Globals.secureStore.reload();

  configureRoutes(Globals.router);

  Globals.client = PiholeClient(dio: Dio(), secureStore: Globals.secureStore);

  final PiholeBloc piholeBloc =
  PiholeBloc(PiholeRepository(Globals.secureStore));

  piholeBloc.dispatch(FetchPiholes());

  final SummaryBloc summaryBloc =
  SummaryBloc(SummaryRepository(Globals.client));

  final VersionsBloc versionsBloc =
  VersionsBloc(VersionsRepository(Globals.client));

  final QueriesOverTimeBloc queriesOverTimeBloc =
  QueriesOverTimeBloc(QueriesOverTimeRepository(Globals.client));

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
    statusBloc.dispatch(Fetch());
    summaryBloc.dispatch(Fetch());
    versionsBloc.dispatch(Fetch());
    queriesOverTimeBloc.dispatch(Fetch());
    queryTypesBloc..dispatch(Fetch());
    forwardDestinationsBloc.dispatch(Fetch());
    topSourcesBloc.dispatch(Fetch());
    topItemsBloc.dispatch(Fetch());
    queryBloc.dispatch(Fetch());
    whitelistBloc.dispatch(Fetch());
    blacklistBloc.dispatch(Fetch());
  };

  assert(() {
    Globals.debug = true;
    return true;
  }());

  if (Globals.debug) {
    BlocSupervisor.delegate = SimpleBlocDelegate();
    Globals.tree.log('main', 'Running in debug mode');
  } else {
    Globals.tree.log('main', 'Running in release mode');
  }

  runApp(App(
    themeModel: ThemeModel(),
    providers: [
      BlocProvider<PiholeBloc>(builder: (context) => piholeBloc),
      BlocProvider<SummaryBloc>(builder: (context) => summaryBloc),
      BlocProvider<VersionsBloc>(builder: (context) => versionsBloc),
      BlocProvider<QueriesOverTimeBloc>(
          builder: (context) => queriesOverTimeBloc),
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
