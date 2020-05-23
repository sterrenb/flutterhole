import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_status.dart';
import 'package:flutterhole/features/settings/blocs/pihole_settings_bloc.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/widgets/layout/indicators/failure_indicators.dart';
import 'package:flutterhole/widgets/layout/indicators/loading_indicators.dart';
import 'package:flutterhole/widgets/layout/notifications/snackbars.dart';

class _SuccessIconButton extends StatelessWidget {
  const _SuccessIconButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        KIcons.success,
        color: KColors.success,
      ),
      onPressed: () {
        showInfoSnackBar(context, 'Host connection established');
      },
    );
  }
}

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
            __,
          ) {
            return hostStatusCode.fold<Widget>(
              (Failure failure) => FailureIconButton(
                failure: failure,
                title: Text('Fetching host status failed'),
              ),
              (int statusCode) {
                return piholeStatus.fold<Widget>(
                  (Failure failure) => FailureIconButton(
                    failure: failure,
                    title: Text('Fetching Pi-hole status failed'),
                  ),
                  (PiStatusEnum piStatus) {
                    switch (piStatus) {
                      case PiStatusEnum.enabled:
                      case PiStatusEnum.disabled:
                        return _SuccessIconButton();
                      case PiStatusEnum.unknown:
                      default:
                        return FailureIconButton(
                          failure: null,
                          title: Text('Unknown Pi-hole status'),
                        );
                    }
                  },
                );
              },
            );
          },
          orElse: () => IconButton(
            icon: LoadingIcon(),
            onPressed: null,
          ),
        );
      },
    );
  }
}
