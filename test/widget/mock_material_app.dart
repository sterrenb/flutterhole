import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/api/blacklist.dart';
import 'package:flutterhole/bloc/api/forward_destinations.dart';
import 'package:flutterhole/bloc/api/queries_over_time.dart';
import 'package:flutterhole/bloc/api/query.dart';
import 'package:flutterhole/bloc/api/query_types.dart';
import 'package:flutterhole/bloc/api/status.dart';
import 'package:flutterhole/bloc/api/versions.dart';
import 'package:flutterhole/bloc/api/whitelist.dart';
import 'package:flutterhole/bloc/pihole/pihole_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:persist_theme/data/models/theme_model.dart';
import 'package:provider/provider.dart';

class MockPiholeBloc extends Mock implements PiholeBloc {}

class MockStatusBloc extends Mock implements StatusBloc {}

class MockVersionsBloc extends Mock implements VersionsBloc {}

class MockQueryTypesBloc extends Mock implements QueryTypesBloc {}

class MockQueriesOverTimeBloc extends Mock implements QueriesOverTimeBloc {}

class MockForwardDestinationsBloc extends Mock
    implements ForwardDestinationsBloc {}

class MockWhitelistBloc extends Mock implements WhitelistBloc {}

class MockBlacklistBloc extends Mock implements BlacklistBloc {}

class MockQueryBloc extends Mock implements QueryBloc {}

class MockThemeModel extends Mock implements ThemeModel {
  Color accentColor;

  MockThemeModel({this.accentColor = Colors.redAccent});
}

class MockThemeListenable extends StatelessWidget {
  final Widget child;
  final MockThemeModel _themeModel;

  MockThemeListenable(
      {Key key, @required this.child, MockThemeModel themeModel})
      : _themeModel = themeModel ?? MockThemeModel(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<ThemeModel>.value(
        value: _themeModel, child: child);
  }
}

class MockMaterialApp extends StatelessWidget {
  final Widget child;
  final Widget appbar;
  final Widget scaffold;

  final MockStatusBloc statusBloc = MockStatusBloc();
  final MockPiholeBloc piholeBloc = MockPiholeBloc();
  final MockVersionsBloc versionsBloc = MockVersionsBloc();
  final MockQueryTypesBloc queryTypesBloc = MockQueryTypesBloc();
  final MockQueriesOverTimeBloc queriesOverTimeBloc = MockQueriesOverTimeBloc();
  final MockForwardDestinationsBloc forwardDestinationsBloc =
  MockForwardDestinationsBloc();
  final MockWhitelistBloc whitelistBloc = MockWhitelistBloc();
  final MockBlacklistBloc blacklistBloc = MockBlacklistBloc();
  final MockQueryBloc queryBloc = MockQueryBloc();

  MockMaterialApp({Key key, this.appbar, this.child, this.scaffold})
      : assert(appbar != null || child != null || scaffold != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PiholeBloc>(builder: (context) => piholeBloc),
        BlocProvider<StatusBloc>(builder: (context) => statusBloc),
        BlocProvider<VersionsBloc>(builder: (context) => versionsBloc),
        BlocProvider<QueryTypesBloc>(builder: (context) => queryTypesBloc),
        BlocProvider<QueriesOverTimeBloc>(
            builder: (context) => queriesOverTimeBloc),
        BlocProvider<ForwardDestinationsBloc>(
            builder: (context) => forwardDestinationsBloc),
        BlocProvider<WhitelistBloc>(builder: (context) => whitelistBloc),
        BlocProvider<BlacklistBloc>(builder: (context) => blacklistBloc),
        BlocProvider<QueryBloc>(builder: (context) => queryBloc),
      ],
      child: MaterialApp(
        title: 'Mock',
        home: scaffold != null
            ? scaffold
            : Scaffold(
          appBar: appbar ?? AppBar(),
          body: MockThemeListenable(child: child ?? Container()),
        ),
      ),
    );
  }
}
