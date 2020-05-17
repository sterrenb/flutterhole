import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/home/blocs/home_bloc.dart';
import 'package:flutterhole/features/numbers_api/blocs/number_trivia_bloc.dart';
import 'package:flutterhole/features/settings/services/preference_service.dart';

/// Fetches trivia data when [HomeBloc] is successful.
class HomeTriviaFetcher extends StatelessWidget {
  const HomeTriviaFetcher({
    Key key,
    this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      child: child,
      listener: (context, state) {
        if (getIt<PreferenceService>().useNumbersApi) {
          state.maybeMap(
              success: (state) {
                state.summary.fold(
                  (failure) {},
                  (summary) {
                    BlocProvider.of<NumberTriviaBloc>(context)
                        .add(NumberTriviaEvent.fetchMany([
                      summary.dnsQueriesToday,
                      summary.adsBlockedToday,
                      summary.adsPercentageToday.round(),
                      summary.domainsBeingBlocked,
                    ]));
                  },
                );
              },
              orElse: () {});
        }
      },
    );
  }
}
