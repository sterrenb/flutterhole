import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutterhole/bloc/blacklist/bloc.dart';
import 'package:flutterhole/bloc/query/bloc.dart';
import 'package:flutterhole/bloc/status/bloc.dart';
import 'package:flutterhole/bloc/summary/bloc.dart';
import 'package:flutterhole/bloc/top_items/bloc.dart';
import 'package:flutterhole/bloc/top_sources/bloc.dart';
import 'package:flutterhole/bloc/whitelist/bloc.dart';
import 'package:flutterhole/model/pihole.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/service/routes.dart';
import 'package:flutterhole/widget/app.dart';
import 'package:mockito/mockito.dart';
import 'package:persist_theme/data/models/theme_model.dart';

import '../test/mock.dart';
import '../test/pihole_client_test.dart';

void main() {
  WidgetsApp.debugAllowBannerOverride = false;
  enableFlutterDriverExtension();
  Globals.router = Router();
  configureRoutes(Globals.router);
  Globals.localStorage = MockLocalStorage();
  when(Globals.localStorage.active()).thenReturn(Pihole());
  runApp(App(themeModel: ThemeModel(), providers: [
    BlocProvider<SummaryBloc>(builder: (context) => MockSummaryBloc()),
    BlocProvider<TopSourcesBloc>(builder: (context) => MockTopSourcesBloc()),
    BlocProvider<TopItemsBloc>(builder: (context) => MockTopItemsBloc()),
    BlocProvider<QueryBloc>(builder: (context) => MockQueryBloc()),
    BlocProvider<StatusBloc>(builder: (context) => MockStatusBloc()),
    BlocProvider<WhitelistBloc>(builder: (context) => MockWhitelistBloc()),
    BlocProvider<BlacklistBloc>(builder: (context) => MockBlacklistBloc()),
  ]));
}
