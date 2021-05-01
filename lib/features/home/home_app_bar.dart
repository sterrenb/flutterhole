import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/dialogs.dart';
import 'package:flutterhole_web/periodic_widget.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:flutterhole_web/settings_screen.dart';
import 'package:hooks_riverpod/all.dart';

class HomeAppBar extends HookWidget implements PreferredSizeWidget {
  const HomeAppBar({Key key})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    final updateFrequency = useProvider(updateFrequencyProvider);

    return AppBar(
      elevation: 0.0,
      title: Row(
        children: [
          ActivePiTitle(),
          PiStatusIcon(),
          PeriodicWidget(
            child: Container(),
            // child: PiTemperatureText(),
            duration: updateFrequency.state,
            onTimer: (timer) {
              // TODO debug
              // context.refresh(piDetailsProvider);
            },
          ),
        ],
      ),
      actions: [
        HomeRefreshIcon(),
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
        PiToggleIconButton(),
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

class PiToggleIconButton extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final piStatus = useProvider(myStatusProvider).state;
    // final piStatus = useProvider(piStatusProvider).state;

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(
            piStatus.when(
              enabled: () => KIcons.disablePihole,
              disabled: () => KIcons.enablePihole,
              error: (error) => Icons.warning,
              sleeping: (duration) => KIcons.wakePihole,
              loading: () => KIcons.enablePihole,
            ),
            color: piStatus.maybeWhen(
              loading: () => Colors.transparent,
              orElse: () => null,
            ),
            // size: 8.0,
          ),
          tooltip: piStatus.when(
            enabled: () => 'Disable Pi-hole',
            disabled: () => 'Enable Pi-hole',
            loading: () => 'Loading',
            error: (error) => error,
            sleeping: (duration) => 'Sleeping $duration',
          ),
          onPressed: piStatus.maybeWhen(
            orElse: () => () {
              context.refresh(enablePiProvider);
            },
          ),
        ),
      ],
    );
  }
}

class HomeRefreshIcon extends HookWidget {
  @override
  Widget build(BuildContext context) => IconButton(
        icon: Icon(KIcons.refresh),
        onPressed: () {
          context.refresh(summaryProvider);
          context.refresh(queryTypesProvider);
          context.refresh(forwardDestinationsProvider);
          context.refresh(piDetailsProvider);
        },
      );
}

class PiStatusIcon extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final piStatus = useProvider(myStatusProvider).state;

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(
            KIcons.dot,
            color: piStatus.when(
              enabled: () => Colors.green,
              disabled: () => Colors.orange,
              error: (_) => Colors.red,
              loading: () => Colors.grey,
              sleeping: (duration) => Colors.blue,
            ),
            size: 8.0,
          ),
          tooltip: piStatus.when(
            enabled: () => 'Enabled',
            disabled: () => 'Disabled',
            error: (error) => error,
            loading: () => 'Loading',
            sleeping: (duration) => 'Sleeping $duration',
          ),
          onPressed: () {},
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
      ],
    );
  }
}
