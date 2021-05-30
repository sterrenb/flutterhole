import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/dialogs.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/features/layout/periodic_widget.dart';
import 'package:flutterhole_web/features/pihole/pi_status.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:flutterhole_web/settings_screen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeAppBar extends HookWidget implements PreferredSizeWidget {
  const HomeAppBar({Key? key})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    final updateFrequency = useProvider(updateFrequencyProvider);

    return AppBar(
      elevation: 0.0,
      // backgroundColor: Theme.of(context).colorScheme.surface,
      title: Row(
        children: [
          ActivePiTitle(),
          PiStatusIndicator(),
          PeriodicWidget(
            child: Container(),
            // child: PiTemperatureText(),
            duration: updateFrequency.state,
            onTimer: (timer) {
              // TODO debug
              // print('onTimer');
              context.refresh(piDetailsProvider);
            },
          ),
        ],
      ),
      actions: [
        // HomeRefreshIcon(),
        IconButton(
          icon: Icon(KIcons.pihole),
          tooltip: 'Select Pi-hole',
          onPressed: () => showActivePiDialog(context, context.read),
        ),
        IconButton(
            icon: Icon(KIcons.settings),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (BuildContext context) => SettingsScreen()),
                )),
        // PiToggleIconButton(),
        // PiSleepIconButton(),
      ],
    );
  }
}

class ActivePiTitle extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final pi = useProvider(activePiProvider);
    return Text(pi.state.title);
  }
}

class HomeRefreshIcon extends HookWidget {
  @override
  Widget build(BuildContext context) => IconButton(
        icon: Icon(KIcons.refresh),
        onPressed: () {
          context.refresh(summaryProvider);
          // context.refresh(queryTypesProvider);
          // context.refresh(forwardDestinationsProvider);
          // context.refresh(piDetailsProvider);
        },
      );
}

class PiToggleIconButton extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final piStatus = useProvider(piholeStatusNotifierProvider) as PiholeStatus;

    return IconButton(
        icon: PiStatusToggleIcon(),
        tooltip: piStatus.when(
          enabled: () => 'Disable Pi-hole',
          disabled: () => 'Enable Pi-hole',
          loading: () => 'Loading',
          error: (error) => error,
          sleeping: (duration, _) => 'Sleeping $duration',
        ),
        onPressed: piStatus.maybeWhen(
          enabled: () => () {
            context.read(piholeStatusNotifierProvider.notifier).disable();
          },
          disabled: () => () {
            context.read(piholeStatusNotifierProvider.notifier).enable();
          },
          orElse: () => null,
        ));
  }
}
