import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/settings/blocs/pihole_settings_bloc.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/widgets/layout/indicators/failure_indicators.dart';
import 'package:flutterhole/widgets/layout/indicators/loading_indicators.dart';
import 'package:flutterhole/widgets/layout/notifications/snackbars.dart';

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
              ___,
            ) {
              return authenticatedStatus.fold<Widget>(
                    (Failure failure) =>
                    FailureIconButton(
                      failure: failure,
                      title: Text('Authentication failed'),
                ),
                (bool isAuthenticated) {
                  return isAuthenticated
                      ? IconButton(
                    icon: Icon(
                      KIcons.success,
                      color: KColors.success,
                    ),
                    onPressed: () {
                      showInfoSnackBar(
                          context, 'Authentication successful');
                    },
                  )
                      : FailureIconButton(
                    failure: Failure('Is your API token correct?'),
                    title: Text('Authentication failed'),
                  );
                },
              );
            },
            orElse: () =>
                IconButton(
                  icon: LoadingIcon(),
                  onPressed: null,
                ));
      },
    );
  }
}
