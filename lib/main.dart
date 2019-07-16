import 'package:dio/dio.dart';
import 'package:fimber/fimber.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole_again/bloc/blacklist/blacklist_bloc.dart';
import 'package:flutterhole_again/bloc/blacklist/blacklist_event.dart';
import 'package:flutterhole_again/bloc/query/query_bloc.dart';
import 'package:flutterhole_again/bloc/query/query_event.dart';
import 'package:flutterhole_again/bloc/status/status_event.dart';
import 'package:flutterhole_again/bloc/summary/summary_event.dart';
import 'package:flutterhole_again/bloc/whitelist/whitelist_event.dart';
import 'package:flutterhole_again/repository/blacklist_repository.dart';
import 'package:flutterhole_again/repository/query_repository.dart';
import 'package:flutterhole_again/repository/summary_repository.dart';
import 'package:flutterhole_again/repository/whitelist_repository.dart';
import 'package:flutterhole_again/service/assert_tree.dart';
import 'package:flutterhole_again/service/globals.dart';
import 'package:flutterhole_again/service/local_storage.dart';
import 'package:flutterhole_again/service/pihole_client.dart';
import 'package:flutterhole_again/service/routes.dart';
import 'package:persist_theme/persist_theme.dart';
import 'package:provider/provider.dart';

import 'bloc/status/status_bloc.dart';
import 'bloc/summary/summary_bloc.dart';
import 'bloc/whitelist/whitelist_bloc.dart';
import 'repository/status_repository.dart';

final _model = ThemeModel();

void main() async {
  Globals.router = Router();
  Globals.localStorage = await LocalStorage.getInstance();
  configureRoutes(Globals.router);

  Globals.client = PiholeClient(dio: Dio(), localStorage: Globals.localStorage);

  assert(() {
    Globals.debug = true;

    return true;
  }());

  if (Globals.debug) {
//    BlocSupervisor.delegate = SimpleBlocDelegate();
    Fimber.plantTree(DebugTree());
    Fimber.i('Running in debug mode');
  } else {
    Fimber.plantTree(AssertTree(['i', 'w', 'e']));
    Fimber.i('Running in release mode');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final SummaryBloc summaryBloc =
      SummaryBloc(SummaryRepository(Globals.client));
  final QueryBloc queryBloc = QueryBloc(QueryRepository(Globals.client));
  final StatusBloc statusBloc = StatusBloc(StatusRepository(Globals.client));
  final WhitelistBloc whitelistBloc =
      WhitelistBloc(WhitelistRepository(Globals.client));
  final BlacklistBloc blacklistBloc =
  BlacklistBloc(BlacklistRepository(Globals.client));

  MyApp() {
    summaryBloc.dispatch(FetchSummary());
    queryBloc.dispatch(FetchQueries());
    statusBloc.dispatch(FetchStatus());
    whitelistBloc.dispatch(FetchWhitelist());
    blacklistBloc.dispatch(FetchBlacklist());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SummaryBloc>(builder: (context) => summaryBloc),
        BlocProvider<QueryBloc>(builder: (context) => queryBloc),
        BlocProvider<StatusBloc>(builder: (context) => statusBloc),
        BlocProvider<WhitelistBloc>(builder: (context) => whitelistBloc),
        BlocProvider<BlacklistBloc>(builder: (context) => blacklistBloc),
      ],
      child: ListenableProvider<ThemeModel>(
        builder: (_) => _model..init(),
        child: Consumer<ThemeModel>(builder: (context, model, child) {
          return MaterialApp(
            title: 'FlutterHole',
            theme: model.theme,
            onGenerateRoute: Globals.router.generator,
          );
        }),
      ),
    );
  }
}
