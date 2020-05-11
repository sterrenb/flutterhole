import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/pihole_api/blocs/pi_connection_bloc.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_status.dart';
import 'package:flutterhole/features/pihole_api/data/models/toggle_status.dart';
import 'package:flutterhole/widgets/layout/loading_indicators.dart';
import 'package:flutterhole/widgets/layout/snackbars.dart';

class PiConnectionToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PiConnectionBloc, PiConnectionState>(
      bloc: getIt<PiConnectionBloc>(),
      listener: (context, state) {
        state.maybeWhen(
          active: (ToggleStatus toggleStatus) {
            switch (toggleStatus.status) {
              case PiStatusEnum.enabled:
//                showInfoSnackBar(context, 'Enabled');
                break;
              case PiStatusEnum.disabled:
//                showInfoSnackBar(context, 'Disabled');
                break;
              case PiStatusEnum.unknown:
              default:
                break;
            }
          },
          failure: (failure) {
            showErrorSnackBar(context, '${failure.toString()}');
          },
          orElse: () {},
        );
      },
      builder: (BuildContext context, state) {
        return state.when<Widget>(
          initial: () => Container(),
          loading: () => IconButton(
            icon: LoadingIcon(),
            onPressed: null,
          ),
          failure: (Failure failure) => IconButton(
            tooltip: 'Try connecting',
            icon: Icon(KIcons.warning, color: KColors.warning),
            onPressed: () {
              getIt<PiConnectionBloc>().add(PiConnectionEvent.ping());
            },
          ),
          active: (ToggleStatus toggleStatus) {
            switch (toggleStatus.status) {
              case PiStatusEnum.enabled:
                return IconButton(
                  tooltip: 'Disable',
                  icon: Icon(KIcons.toggleDisable),
                  onPressed: () {
                    getIt<PiConnectionBloc>().add(PiConnectionEvent.disable());
                  },
                );
              case PiStatusEnum.disabled:
                return IconButton(
                  tooltip: 'Enable',
                  icon: Icon(KIcons.toggleEnable),
                  onPressed: () {
                    getIt<PiConnectionBloc>().add(PiConnectionEvent.enable());
                  },
                );
              case PiStatusEnum.unknown:
              default:
                return Container();
            }
          },
        );
      },
    );
  }
}
