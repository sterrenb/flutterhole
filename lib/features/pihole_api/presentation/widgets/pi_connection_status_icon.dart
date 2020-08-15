import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/core/convert.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/pihole_api/blocs/pi_connection_bloc.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_status.dart';
import 'package:flutterhole/features/pihole_api/data/models/toggle_status.dart';
import 'package:flutterhole/widgets/layout/animations/timer_builder.dart';
import 'package:flutterhole/widgets/layout/notifications/toasts.dart';
import 'package:supercharged/supercharged.dart';

const _$PiStatusEnumEnumMap = {
  PiStatusEnum.enabled: 'enabled',
  PiStatusEnum.disabled: 'disabled',
  PiStatusEnum.unknown: 'unknown',
};

class PiConnectionStatusIcon extends StatelessWidget {
  const PiConnectionStatusIcon({
    Key key,
    this.interactive = false,
  }) : super(key: key);

  final bool interactive;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PiConnectionBloc, PiConnectionState>(
        cubit: getIt<PiConnectionBloc>(),
        builder: (BuildContext context, state) {
          final Color color = state.when(
            initial: () => KColors.inactive,
            loading: () => KColors.loading,
            failure: (_) => KColors.error,
            active: (settings, ToggleStatus toggleStatus) {
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
            sleeping: (
              _,
              __,
              ___,
            ) =>
                KColors.sleeping,
          );

          return IconButton(
            icon: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Icon(
                  KIcons.color,
                  size: 8.0,
                  color: color,
                ),
                _SleepProgressIndicator(),
              ],
            ),
            onPressed: interactive
                ? getIt<PiConnectionBloc>().state.when<VoidCallback>(
                      initial: () => null,
                      loading: () => null,
                      failure: (failure) => () {
                        showToast(
                            '${failure.message}: ${failure.error?.toString()}');
                      },
                      active: (settings, toggleStatus) => () {
                        showToast(
                            '${settings.title} is ${_$PiStatusEnumEnumMap[toggleStatus.status]}');
                      },
                      sleeping: (_, start, duration) => () {
                        final dateTime = start.add(duration);
                        showToast(
                            'Sleeping until ${dateTime.formattedTime} (${dateTime.fromNow})');
                      },
                    )
                : null,
          );
        });
  }
}

class _SleepProgressIndicator extends StatelessWidget {
  const _SleepProgressIndicator({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PiConnectionBloc, PiConnectionState>(
        cubit: getIt<PiConnectionBloc>(),
        builder: (BuildContext context, state) {
          return state.maybeWhen<Widget>(
              sleeping: (_, DateTime start, Duration duration) {
                return TimerBuilder(
                  duration: 1.seconds,
                  builder: (context) {
                    final Duration diff = clock.now().difference(start);
                    final double percentage = diff / duration;

                    if (percentage >= 1) {
                      // TODO this check in the build method sucks.
                      // It can trigger multiple times and should somehow be
                      // scheduled properly by the bloc itself.
                      getIt<PiConnectionBloc>().add(PiConnectionEvent.enable());
                    }

                    return SizedBox(
                      width: 16.0,
                      height: 16.0,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(KColors.sleeping),
                        value: (1 - percentage),
                      ),
                    );
                  },
                );
              },
              orElse: () => Container());
        });
  }
}
