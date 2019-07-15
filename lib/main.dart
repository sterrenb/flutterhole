import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:fimber/fimber.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole_again/bloc/blacklist/blacklist_bloc.dart';
import 'package:flutterhole_again/repository/blacklist_repository.dart';
import 'package:flutterhole_again/repository/summary_repository.dart';
import 'package:flutterhole_again/repository/whitelist_repository.dart';
import 'package:flutterhole_again/service/globals.dart';
import 'package:flutterhole_again/service/local_storage.dart';
import 'package:flutterhole_again/service/pihole_client.dart';
import 'package:flutterhole_again/service/routes.dart';
import 'package:persist_theme/persist_theme.dart';
import 'package:provider/provider.dart';

import 'bloc/simple_bloc_delegate.dart';
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
    BlocSupervisor.delegate = SimpleBlocDelegate();
    Fimber.plantTree(DebugTree());
    Fimber.i('Running in debug mode');
    return true;
  }());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final SummaryBloc summaryBloc =
      SummaryBloc(SummaryRepository(Globals.client));
  final StatusBloc statusBloc = StatusBloc(StatusRepository(Globals.client));
  final WhitelistBloc whitelistBloc =
      WhitelistBloc(WhitelistRepository(Globals.client));
  final BlacklistBloc blacklistBloc =
  BlacklistBloc(BlacklistRepository(Globals.client));

  @override
  Widget build(BuildContext context) {
    return BlocProviderTree(
      blocProviders: [
        BlocProvider<SummaryBloc>(
            dispose: false, builder: (context) => summaryBloc),
        BlocProvider<StatusBloc>(
            dispose: false, builder: (context) => statusBloc),
        BlocProvider<WhitelistBloc>(
            dispose: false, builder: (context) => whitelistBloc),
        BlocProvider<BlacklistBloc>(
            dispose: false, builder: (context) => blacklistBloc),
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
