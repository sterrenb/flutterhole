import 'package:flutter/material.dart';
import 'package:flutterhole/core/debug/bloc_delegate.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/routing/services/router_service.dart';
import 'package:flutterhole/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:injectable/injectable.dart';

import 'features/settings/data/datasources/settings_data_source.dart';

void main() async {
  // wait for flutter initialization
  WidgetsFlutterBinding.ensureInitialized();

  await configure(Environment.prod);
  enableBlocDelegate();
  getIt<RouterService>().createRoutes();

  getIt<SettingsBloc>().add(SettingsEvent.init());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: getIt<RouterService>().navigatorKey,
      onGenerateRoute: getIt<RouterService>().onGenerateRoute,
      initialRoute: RouterService.home,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class DebugHome extends StatelessWidget {
  const DebugHome({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
            onPressed: () async {
              final settings = getIt<SettingsDataSource>();
              final all = await settings.fetchAllPiholeSettings();
              print(all);
            },
            child: Text('print all'),
          ),
          RaisedButton(
            onPressed: () async {
              final settings = getIt<SettingsDataSource>();
              final res = await settings.createPiholeSettings();
              print(res);
            },
            child: Text('print create'),
          ),
        ],
      ),
    );
  }
}
