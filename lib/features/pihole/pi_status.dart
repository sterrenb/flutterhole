import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/features/layout/dialog.dart';
import 'package:flutterhole_web/features/layout/periodic_widget.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PiStatusIcon extends HookWidget {
  const PiStatusIcon({
    Key? key,
    this.size,
  }) : super(key: key);

  final double? size;

  @override
  Widget build(BuildContext context) {
    // final piStatus = useProvider(piholeStatusProvider).state;
    final piStatus = useProvider(piholeStatusNotifierProvider) as PiholeStatus;

    return Icon(
      KIcons.dot,
      color: piStatus.when(
        enabled: () => Colors.green,
        disabled: () => Colors.orange,
        error: (_) => Colors.red,
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
    final piStatus = useProvider(piholeStatusNotifierProvider) as PiholeStatus;

    final icon = Icon(
      piStatus.when(
        enabled: () => KIcons.disablePihole,
        disabled: () => KIcons.enablePihole,
        error: (error) => Icons.warning,
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
                color: Theme.of(context).textTheme.bodyText1?.color,
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
    this.enabled = true,
  }) : super(key: key);

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    // final piStatus = useProvider(piholeStatusProvider).state;
    final piStatus = useProvider(piholeStatusNotifierProvider) as PiholeStatus;

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
            error: (error) => error,
            loading: () => 'Loading',
            sleeping: (duration, _) =>
                'Sleeping for ${duration.inSeconds - tick.value} seconds',
          ),
          onPressed: enabled ? () {} : null,
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
        piStatus.maybeWhen(
          sleeping: (duration, start) {
            final progress = tick.value / duration.inSeconds;
            return PeriodicWidget(
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: SizedBox(
                    width: 14.0,
                    height: 14.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(KColors.sleeping),
                      value: 1 - progress,
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

class PiToggleFloatingActionButton extends HookWidget {
  @override
  Widget build(BuildContext context) {
    // final piStatus = useProvider(piholeStatusProvider).state;
    final piStatus = useProvider(piholeStatusNotifierProvider) as PiholeStatus;

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
          orElse: () => null,
        ),
      ),
    );
  }
}
