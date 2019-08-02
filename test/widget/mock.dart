import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/api/status.dart';
import 'package:flutterhole/bloc/api/versions.dart';
import 'package:flutterhole/bloc/pihole/pihole_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:persist_theme/data/models/theme_model.dart';
import 'package:provider/provider.dart';

class MockPiholeBloc extends Mock implements PiholeBloc {}

class MockStatusBloc extends Mock implements StatusBloc {}

class MockVersionsBloc extends Mock implements VersionsBloc {}

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

  final MockStatusBloc statusBloc = MockStatusBloc();
  final MockPiholeBloc piholeBloc = MockPiholeBloc();
  final MockVersionsBloc versionsBloc = MockVersionsBloc();

  MockMaterialApp({Key key, this.child, this.appbar}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PiholeBloc>(builder: (context) => piholeBloc),
        BlocProvider<StatusBloc>(builder: (context) => statusBloc),
        BlocProvider<VersionsBloc>(builder: (context) => versionsBloc),
      ],
      child: MaterialApp(
        title: 'Mock',
        home: Scaffold(
          appBar: appbar ?? AppBar(),
          body: MockThemeListenable(child: child ?? Container()),
        ),
      ),
    );
  }
}
