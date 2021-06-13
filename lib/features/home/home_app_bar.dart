import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/dialogs.dart';
import 'package:flutterhole_web/features/pihole/pi_status.dart';
import 'package:flutterhole_web/features/routing/app_router.gr.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:flutterhole_web/top_level_providers.dart';
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
    final pi = useProvider(activePiProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: AppBar(
        elevation: 0.0,
        // backgroundColor: Theme.of(context).colorScheme.surface,
        titleSpacing: 0.0,
        title: PiStatusMessenger(
          builder: (context) => Container(
            // color: Colors.red,
            child: Row(
              children: [
                TextButton(
                  onLongPress: () {
                    // AutoRouter
                    context.router.push(SinglePiRoute(
                      initial: pi,
                      onSave: (update) {
                        context
                            .read(settingsNotifierProvider.notifier)
                            .savePi(update);

                        context
                            .read(piholeStatusNotifierProvider.notifier)
                            .ping();
                      },
                    ));
                  },
                  onPressed: () => showActivePiDialog(context, context.read),
                  child: Text(
                    pi.title,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                PiStatusIndicator(
                  onTap: () {
                    context.read(piholeStatusNotifierProvider.notifier).ping();
                  },
                ),
                // PeriodicWidget(
                //   child: Container(),
                //   // child: PiTemperatureText(),
                //   duration: updateFrequency.state,
                //   onTimer: (timer) {
                //     // TODO debug
                //     // print('onTimer');
                //     // context.refresh(piDetailsProvider(pi));
                //     // context
                //     //     .refresh(piSummaryProvider(context.read(simplePiProvider)));
                //   },
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PiToggleIconButton extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final piStatus = useProvider(piholeStatusNotifierProvider);

    return IconButton(
        icon: PiStatusToggleIcon(),
        tooltip: piStatus.when(
          enabled: () => 'Disable Pi-hole',
          disabled: () => 'Enable Pi-hole',
          loading: () => 'Loading',
          failure: (error) => error.toString(),
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
