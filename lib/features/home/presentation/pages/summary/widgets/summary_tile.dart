import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/numbers_api/blocs/number_trivia_bloc.dart';
import 'package:flutterhole/features/numbers_api/presentation/widgets/numbers_api_description_tile.dart';
import 'package:flutterhole/features/settings/services/preference_service.dart';
import 'package:flutterhole/widgets/layout/animate_on_build.dart';
import 'package:flutterhole/widgets/layout/loading_indicators.dart';

class SummaryTile extends StatelessWidget {
  const SummaryTile({
    Key key,
    @required this.title,
    @required this.subtitle,
    @required this.integer,
    @required this.color,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final int integer;
  final Color color;

  bool get _useNumbersApi =>
      getIt<PreferenceService>().get(KPrefs.useNumbersApi) ?? true;

  @override
  Widget build(BuildContext context) {
    if (!_useNumbersApi) {
      return Card(
        color: color,
        child: _Tile(title, subtitle),
      );
    } else {
      return Card(
        child: OpenContainer(
          tappable: false,
          closedColor: color,
          closedBuilder: (context, VoidCallback openContainer) {
            return InkWell(
              onTap: openContainer,
              child: _Tile(title, subtitle),
            );
          },
          openBuilder: (_, __) {
            return BlocProvider<NumberTriviaBloc>.value(
              value: BlocProvider.of<NumberTriviaBloc>(context),
              child: _SummaryTriviaPage(
                color: color,
                title: title,
                subtitle: subtitle,
                integer: integer,
              ),
            );
          },
        ),
      );
    }
  }
}

class _SummaryTriviaPage extends StatelessWidget {
  const _SummaryTriviaPage({
    Key key,
    @required this.color,
    @required this.title,
    @required this.subtitle,
    @required this.integer,
  }) : super(key: key);

  final Color color;
  final String title;
  final String subtitle;
  final int integer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: AnimateOnBuild(
        child: Stack(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _Tile(title, subtitle),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
                    bloc: BlocProvider.of<NumberTriviaBloc>(context),
                    builder: (BuildContext context, NumberTriviaState state) {
                      return state.maybeWhen(
                        success: (trivia) {
                          if (trivia.containsKey(integer)) {
                            return Text(
                              '${trivia[integer]}',
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .headline6
                                  .copyWith(color: Colors.white),
                              textAlign: TextAlign.center,
                            );
                          }

                          return Text(
                            'No data for ${integer} in $trivia',
                            style: Theme
                                .of(context)
                                .textTheme
                                .bodyText1
                                .apply(color: Colors.white),
                          );
                        },
                        loading: () =>
                            CenteredLoadingIndicator(
                              color: Colors.white,
                            ),
                        orElse: () => Container(),
                      );
                    },
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: NumbersApiDescriptionTile(integer: integer),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(
    this.title,
    this.subtitle, {
    Key key,
  }) : super(key: key);

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: Text(
            title,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
        Center(
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
