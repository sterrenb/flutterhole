import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole_again/bloc/blacklist/bloc.dart';
import 'package:flutterhole_again/bloc/query/bloc.dart';
import 'package:flutterhole_again/bloc/status/bloc.dart';
import 'package:flutterhole_again/bloc/summary/bloc.dart';
import 'package:flutterhole_again/bloc/whitelist/bloc.dart';
import 'package:flutterhole_again/service/globals.dart';
import 'package:persist_theme/persist_theme.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  final _model = ThemeModel();

  final SummaryBloc summaryBloc =
      SummaryBloc(SummaryRepository(Globals.client));

  final QueryBloc queryBloc = QueryBloc(QueryRepository(Globals.client));

  final StatusBloc statusBloc = StatusBloc(StatusRepository(Globals.client));

  final WhitelistBloc whitelistBloc =
      WhitelistBloc(WhitelistRepository(Globals.client));

  final BlacklistBloc blacklistBloc =
      BlacklistBloc(BlacklistRepository(Globals.client));

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
