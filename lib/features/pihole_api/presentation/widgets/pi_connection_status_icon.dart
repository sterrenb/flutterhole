import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/pihole_api/blocs/pi_connection_bloc.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_status.dart';
import 'package:flutterhole/features/pihole_api/data/models/toggle_status.dart';

class PiConnectionStatusIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PiConnectionBloc, PiConnectionState>(
        bloc: getIt<PiConnectionBloc>(),
        builder: (BuildContext context, state) {
          final Color color = state.when(
            initial: () => KColors.inactive,
            loading: () => KColors.loading,
            failure: (_) => KColors.error,
            active: (ToggleStatus toggleStatus) {
              switch (toggleStatus.status) {
                case PiStatusEnum.enabled:
                  return KColors.enabled;
                case PiStatusEnum.disabled:
                  return KColors.disabled;
                case PiStatusEnum.unknown:
                default:
                  return KColors.unknown;
              }
            },
          );

          return IconButton(
            icon: Icon(KIcons.color,
              size: 8.0,
              color: color,),
            onPressed: null,
          );
        });
  }
}
