import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/dialogs.dart';
import 'package:flutterhole_web/features/entities/api_entities.dart';
import 'package:flutterhole_web/features/layout/dialog.dart';
import 'package:flutterhole_web/features/layout/periodic_widget.dart';
import 'package:flutterhole_web/features/layout/snackbar.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:flutterhole_web/top_level_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PiStatusIcon extends HookWidget {
  const PiStatusIcon({
    Key? key,
    this.size,
  }) : super(key: key);

  final double? size;

  @override
  Widget build(BuildContext context) {
    final piStatus = useProvider(piholeStatusNotifierProvider);

    return Icon(
      KIcons.dot,
      color: piStatus.when(
        enabled: () => Colors.green,
        disabled: () => Colors.orange,
        failure: (_) => Colors.red,
        loading: () => Colors.grey,
        sleeping: (_, __) => Colors.blue,
      ),
      size: size,
    );
  }
}

class PiStatusToggleIcon extends HookWidget {
  const PiStatusToggleIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final piStatus = useProvider(piholeStatusProvider).state;
    final piStatus = useProvider(piholeStatusNotifierProvider);

    final icon = Icon(
      piStatus.when(
        enabled: () => KIcons.disablePihole,
        disabled: () => KIcons.enablePihole,
        failure: (error) => Icons.warning,
        sleeping: (_, __) => KIcons.wakePihole,
        loading: () => KIcons.enablePihole,
      ),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedSwitcher(
          duration: kThemeAnimationDuration,
          child: piStatus.maybeWhen(
            loading: () => SizedBox(
              width: 14.0,
              height: 14.0,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            orElse: () => icon,
          ),
        ),
        // _LoadingIndicator(),
      ],
    );
  }
}

class PiStatusIndicator extends HookWidget {
  const PiStatusIndicator({
    Key? key,
    this.onTap,
  }) : super(key: key);

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // final piStatus = useProvider(piholeStatusProvider).state;
    final PiholeStatus piStatus = useProvider(piholeStatusNotifierProvider);

    final tick = useState<int>(0);

    useEffect(() {
      piStatus.maybeWhen(
        sleeping: (_, __) {
          tick.value = 0;
        },
        orElse: () {},
      );
    }, [piStatus]);

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: PiStatusIcon(size: 8.0),
          tooltip: piStatus.when(
            enabled: () => 'Enabled',
            disabled: () => 'Disabled',
            failure: (error) => error.toString(),
            loading: () => 'Loading',
            sleeping: (duration, _) =>
                'Sleeping for ${duration.inSeconds - tick.value} seconds',
          ),
          onPressed: onTap,
        ),
        IgnorePointer(
          child: AnimatedOpacity(
            duration: kThemeAnimationDuration,
            opacity: piStatus.maybeWhen(loading: () => 1.0, orElse: () => 0.0),
            child: SizedBox(
              width: 14.0,
              height: 14.0,
              child: CircularProgressIndicator(strokeWidth: 2.0),
            ),
          ),
        ),
        piStatus.maybeWhen<Widget>(
          sleeping: (duration, start) {
            // final progress = tick.value / duration.inSeconds;
            final Duration diff = DateTime.now().difference(start);
            final double progress = diff.inSeconds / duration.inSeconds;
            // return 0;
            return PeriodicWidget(
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: SizedBox(
                    width: 14.0,
                    height: 14.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(KColors.sleeping),
                      value: progress,
                      strokeWidth: 2.0,
                    ),
                  ),
                ),
                duration: Duration(seconds: 1),
                onTimer: (_) {
                  tick.value += 1;
                });
          },
          orElse: () => Container(),
        ),
      ],
    );
  }
}

extension TimeOfDayX on TimeOfDay {
  int get inMinutes => hour * 60 + minute;
}

void useAsyncEffect(
  FutureOr<dynamic> Function() effect, {
  FutureOr<dynamic> Function()? cleanup,
  List<Object>? keys,
}) {
  useEffect(() {
    Future.microtask(effect);
    return () {
      if (cleanup != null) {
        Future.microtask(cleanup);
      }
    };
  }, keys);
}

class PiStatusMessenger extends HookWidget {
  const PiStatusMessenger({
    Key? key,
    required this.builder,
  }) : super(key: key);

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final PiholeStatus piStatus = useProvider(piholeStatusNotifierProvider);
    final debugMode = useProvider(debugModeProvider);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    useAsyncEffect(() {
      final message = piStatus.when<String?>(
        loading: () => debugMode ? 'Loading' : null,
        enabled: () => debugMode ? 'Enabled' : null,
        disabled: () => debugMode ? 'Disabled' : null,
        sleeping: (duration, start) => 'Sleeping',
        failure: (e) {
          return e.when(
            notFound: () => 'Not found',
            notAuthenticated: () => 'notAuthenticated',
            invalidResponse: (statusCode) => 'invalidResponse',
            emptyString: () => 'emptyString',
            emptyList: () => 'emptyList',
            cancelled: () => 'cancelled',
            timeout: () => 'timeout',
            hostname: () => 'hostname',
            general: (message) => message,
            unknown: (e) => 'unknown',
          );
        },
      );

      if (message != null) {
        messenger.showThemedMessageNow(context, message: message);
      }
    }, keys: [messenger, piStatus]);

    return builder(context);
  }
}

class PiToggleFloatingActionButton extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final piStatus = useProvider(piholeStatusNotifierProvider);
    // final piStatus = watch(piholeStatusNotifierProvider);

    Future<Duration?> showCustomSleepDialog() async {
      final now = TimeOfDay.now();
      final timePicked = await showTimePicker(
        context: context,
        initialTime: now,
        helpText: 'Sleep until...',
      );
      if (timePicked != null) {
        if (timePicked.inMinutes == now.inMinutes) {
          return null;
        }
        int minutes = timePicked.inMinutes - now.inMinutes;
        if (timePicked.inMinutes < now.inMinutes) {
          minutes += 24 * 60;
        }
        return Duration(hours: (minutes / 60).floor(), minutes: minutes % 60);
      }
    }

    Future<Duration?> showSleepDialog() async {
      final result = await showOptionDialog<Duration>(
        context: context,
        title: Text('Sleep for...'),
        options: [
          OptionDialogItem(option: Duration(seconds: 1), title: '1 second'),
          OptionDialogItem(option: Duration(seconds: 10), title: '10 seconds'),
          OptionDialogItem(option: Duration(seconds: 30), title: '30 seconds'),
          OptionDialogItem(option: Duration(minutes: 5), title: '5 minutes'),
          OptionDialogItem(option: Duration.zero, title: 'Custom time'),
        ],
      );

      if (result == Duration.zero) {
        return await showCustomSleepDialog();
      }

      return result;
    }

    Future<void> onSleep() async {
      final duration = await showSleepDialog();
      if (duration != null) {
        context.read(piholeStatusNotifierProvider.notifier).sleep(duration);
      }
    }

    return GestureDetector(
      onLongPress: piStatus.maybeWhen(
        enabled: () => onSleep,
        disabled: () => onSleep,
        orElse: () => null,
      ),
      child: FloatingActionButton(
        child: PiStatusToggleIcon(),
        tooltip: piStatus.maybeWhen(
          sleeping: (duration, _) => 'Wake up',
          orElse: () => null,
        ),
        onPressed: piStatus.maybeWhen(
          enabled: () => () {
            context.read(piholeStatusNotifierProvider.notifier).disable();
          },
          disabled: () => () {
            context.read(piholeStatusNotifierProvider.notifier).enable();
          },
          sleeping: (_, __) => () {
            context.read(piholeStatusNotifierProvider.notifier).enable();
          },
          failure: (failure) => () {
            showErrorDialog(context, failure);
          },
          orElse: () => null,
        ),
      ),
    );
  }
}
