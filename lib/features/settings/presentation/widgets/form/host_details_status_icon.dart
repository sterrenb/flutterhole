import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_status.dart';
import 'package:flutterhole/features/settings/blocs/pihole_settings_bloc.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/widgets/layout/loading_indicators.dart';

class HostDetailsStatusIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PiholeSettingsBloc, PiholeSettingsState>(
      builder: (BuildContext context, PiholeSettingsState state) {
        return state.maybeWhen<Widget>(
            validated: (
              PiholeSettings settings,
              dartz.Either<Failure, int> hostStatusCode,
              dartz.Either<Failure, PiStatusEnum> piholeStatus,
              _,
            ) {
              return hostStatusCode.fold<Widget>(
                (Failure failure) => Icon(
                  KIcons.error,
                  color: KColors.error,
                ),
                (int statusCode) {
                  return piholeStatus.fold<Widget>(
                    (Failure failure) => Icon(
                      KIcons.error,
                      color: KColors.error,
                    ),
                    (PiStatusEnum piStatus) {
                      switch (piStatus) {
                        case PiStatusEnum.enabled:
                        case PiStatusEnum.disabled:
                          return Icon(
                            KIcons.success,
                            color: KColors.success,
                          );
                        case PiStatusEnum.unknown:
                        default:
                          return Icon(
                            KIcons.error,
                            color: KColors.error,
                          );
                      }
                    },
                  );
                },
              );
            },
            loading: () => LoadingIcon(),
            orElse: () => Icon(
                  KIcons.debug,
                  color: Colors.transparent,
                ));
      },
    );
  }
}
