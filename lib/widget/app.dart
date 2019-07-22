import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:persist_theme/persist_theme.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  final ThemeModel themeModel;

  final List<BlocProvider> providers;

  App({Key key, @required this.themeModel, @required this.providers})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: providers,
      child: ListenableProvider<ThemeModel>(
        builder: (_) => themeModel..init(),
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
