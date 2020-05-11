import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/settings/blocs/pihole_settings_bloc.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/widgets/layout/loading_indicators.dart';

class AuthenticationStatusIcon extends StatelessWidget {
  const AuthenticationStatusIcon({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PiholeSettingsBloc, PiholeSettingsState>(
      builder: (BuildContext context, PiholeSettingsState state) {
        return state.maybeWhen<Widget>(
            validated: (
              PiholeSettings settings,
              _,
              __,
              dartz.Either<Failure, bool> authenticatedStatus,
            ) {
              return authenticatedStatus.fold<Widget>(
                (Failure failure) => Icon(
                  KIcons.error,
                  color: KColors.error,
                ),
                (bool isAuthenticated) {
                  return Icon(
                    isAuthenticated ? KIcons.success : KIcons.error,
                    color: isAuthenticated ? KColors.success : KColors.error,
                  );
                },
              );
            },
            loading: () => LoadingIcon(),
            orElse: () => Icon(KIcons.debug));
      },
    );
  }
}
