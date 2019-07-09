import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:fimber/fimber.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole_again/repository/summary_repository.dart';
import 'package:flutterhole_again/service/globals.dart';
import 'package:flutterhole_again/service/local_storage.dart';
import 'package:flutterhole_again/service/pihole_client.dart';
import 'package:flutterhole_again/service/routes.dart';

import 'bloc/simple_bloc_delegate.dart';
import 'bloc/status/bloc.dart';
import 'bloc/summary/bloc.dart';
import 'repository/status_repository.dart';

void main() async {
  Globals.router = Router();
  Globals.localStorage = await LocalStorage.getInstance();
  configureRoutes(Globals.router);

  Globals.client = PiholeClient(
      dio: Dio(), localStorage: Globals.localStorage);

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

  @override
  Widget build(BuildContext context) {
    return BlocProviderTree(
      blocProviders: [
        BlocProvider<SummaryBloc>(
            dispose: false, builder: (context) => summaryBloc),
        BlocProvider<StatusBloc>(
            dispose: false, builder: (context) => statusBloc)
      ],
      child: MaterialApp(
        title: 'FlutterHole',
        onGenerateRoute: Globals.router.generator,
      ),
    );
  }
}
