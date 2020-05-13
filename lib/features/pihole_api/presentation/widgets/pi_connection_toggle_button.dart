import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/pihole_api/blocs/pi_connection_bloc.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_status.dart';
import 'package:flutterhole/features/pihole_api/data/models/toggle_status.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/widgets/layout/loading_indicators.dart';
import 'package:flutterhole/widgets/layout/snackbars.dart';
import 'package:flutterhole/widgets/layout/toasts.dart';

class PiConnectionToggleButton extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PiConnectionBloc, PiConnectionState>(
      bloc: getIt<PiConnectionBloc>(),
      listener: (BuildContext context, PiConnectionState state) {
        state.maybeWhen(
          active: (settings, ToggleStatus toggleStatus) {
            switch (toggleStatus.status) {
              case PiStatusEnum.enabled:
                showToast('Enabled');
                break;
              case PiStatusEnum.disabled:
                showToast('Disabled');
                break;
              case PiStatusEnum.unknown:
              default:
                showToast('Unknown');
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
            tooltip: 'Try reconnecting',
            icon: Icon(KIcons.warning, color: KColors.warning),
            onPressed: () {
              getIt<PiConnectionBloc>().add(PiConnectionEvent.ping());
            },
          ),
          active: (settings, ToggleStatus toggleStatus) {
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
          sleeping:
              (PiholeSettings settings, DateTime start, Duration duration) {
            return IconButton(
              tooltip: 'Wake up',
              icon: Icon(KIcons.wake),
              onPressed: () {
                getIt<PiConnectionBloc>().add(PiConnectionEvent.enable());
              },
            );
          },
        );
      },
    );
  }
}
