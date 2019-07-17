import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:fimber/fimber.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole_again/bloc/simple_bloc_delegate.dart';
import 'package:flutterhole_again/service/assert_tree.dart';
import 'package:flutterhole_again/service/globals.dart';
import 'package:flutterhole_again/service/local_storage.dart';
import 'package:flutterhole_again/service/pihole_client.dart';
import 'package:flutterhole_again/service/routes.dart';
import 'package:flutterhole_again/widget/app.dart';

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
    BlocSupervisor.delegate = SimpleBlocDelegate();
    Fimber.plantTree(DebugTree());
    Fimber.i('Running in debug mode');
  } else {
    Fimber.plantTree(AssertTree(['i', 'w', 'e']));
    Fimber.i('Running in release mode');
  }

  runApp(App());
}
