import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/services/api_service.dart';
import 'package:flutterhole/widgets/layout/animations.dart';
import 'package:flutterhole/widgets/layout/centered_leading.dart';
import 'package:flutterhole/widgets/layout/loading_indicator.dart';
import 'package:flutterhole/widgets/layout/responsiveness.dart';
import 'package:flutterhole/widgets/ui/dialogs.dart';
import 'package:flutterhole/widgets/ui/scaffold_messenger.dart';
import 'package:flutterhole/widgets/ui/snackbars.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pihole_api/pihole_api.dart';

class PingApiButton extends HookConsumerWidget {
  const PingApiButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = ref.watch(activePiholeParamsProvider);
    // final ping = ref.watch(pingProvider(params));
    final ping = ref.watch(activePingProvider);

    return ListTile(
      title: Text("Pi-hole status ${params.apiUrl}"),
      onTap: ping.maybeWhen(
          error: (e, s) => () {
                showModal(
                    context: context,
                    builder: (context) => ErrorDialog(
                          title: "Pi-hole status",
                          error: e,
                          stackTrace: s,
                        ));
              },
          orElse: () => null),
      subtitle: Wrap(
        children: [
          AnimatedFader(
            child: ping.when(
              data: (status) => Text(Formatting.piholeStatusToString(status)),
              error: (e, s) => Text(
                Formatting.errorToDescription(e),
                overflow: TextOverflow.ellipsis,
              ),
              loading: () => Container(),
            ),
          ),
        ],
      ),
      leading: CenteredLeading(
        child: AnimatedFader(
          child: ping.when(
            data: (status) => Icon(
              KIcons.success,
              color: Theme.of(context).colorScheme.primary,
            ),
            error: (e, s) => Icon(
              KIcons.error,
              color: Theme.of(context).colorScheme.error,
            ),
            loading: () => const LoadingIndicator(),
          ),
        ),
      ),
      trailing: OutlinedButton(
        onPressed: ping.maybeWhen(
          loading: () => null,
          orElse: () => () {
            ref.refresh(pingProvider(params));
          },
        ),
        child: const Text("Refresh"),
      ),
    );
  }
}

class PingFloatingActionButton extends HookConsumerWidget {
  const PingFloatingActionButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ping = ref.watch(PingNotifier.provider);
    final api = ref.watch(PingNotifier.provider.notifier);
    final status = ping.status;
    final isLoading = ping.loading;
    final error = ping.error ?? 'Loading';
    final mounted = useIsMounted();

    useAsyncEffect(
      () {
        if (error != 'Loading') {
          highlightSnackBar(
            context,
            content:
                Text('Disconnected: ${Formatting.errorToDescription(error)}.'),
          );
        }
      },
      () {},
      [error],
    );

    useAsyncEffect(
      () {
        status.maybeWhen(
          sleeping: (duration, start) {
            highlightSnackBar(
              context,
              content: Text('Sleeping for ${duration.toHms()}.'),
              undo: () => api.enable(),
            );
          },
          orElse: () {
            clearSnackBars(context);
          },
        );
      },
      () {},
      [status],
    );

    Future<void> sleep(Duration duration) async {
      final now = DateTime.now();
      await api.sleep(duration, now);
      await Future.delayed(duration);
      if (mounted()) {
        api.ping();
      }
    }

    void showSleepDialog() async {
      final selectedDuration = await showModal<Duration>(
        context: context,
        builder: (context) => const _SleepForDialog(),
      );
      if (selectedDuration == null) {
        return;
      } else if (selectedDuration != Duration.zero) {
        return sleep(selectedDuration);
      } else {
        final now = TimeOfDay.now();
        final timeOfDay = await showModal<TimeOfDay>(
            context: context,
            builder: (context) => TimePickerDialog(
                  initialTime: now,
                  confirmText: 'Sleep'.toUpperCase(),
                  helpText: 'Sleep until...'.toUpperCase(),
                ));

        if (timeOfDay == null || timeOfDay == now) return;
        return sleep(timeOfDay.absoluteDuration());
      }
    }

    return BreakpointBuilder(builder: (context, isBig) {
      return GestureDetector(
        onLongPress: status.maybeWhen(
          enabled: () => showSleepDialog,
          disabled: () => showSleepDialog,
          orElse: () {},
        ),
        child: FloatingActionButton.extended(
          extendedTextStyle: Theme.of(context)
              .textTheme
              .subtitle1
              ?.copyWith(color: Theme.of(context).colorScheme.secondary),
          onPressed: () => isLoading
              ? api.ping()
              : status.map(
                  enabled: (_) => api.disable(),
                  disabled: (_) => api.enable(),
                  sleeping: (_) => api.enable(),
                ),
          icon: const _StatusIcon(),
          label: DefaultAnimatedSize(
            child: AnimatedStack(
              children: const [
                Text('Disable'),
                Text('Enable'),
                Text('Enable'),
                Text('Disconnected'),
              ],
              active: ping.error != null
                  ? 3
                  : status.when(
                      enabled: () => 0,
                      disabled: () => 1,
                      sleeping: (duration, start) => 2,
                    ),
            ),
          ),
        ),
      );
    });
  }
}

class _SleepForDialog extends StatelessWidget {
  const _SleepForDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModalAlertDialog<Duration>(
      backgroundColor: Theme.of(context).bottomAppBarColor,
      title: 'Sleep for...',
      canOk: false,
      canCancel: false,
      contentPadding: EdgeInsets.zero,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8.0),
            ...[
              if (kDebugMode) ...[
                const Duration(seconds: 1),
                const Duration(seconds: 5),
              ],
              const Duration(seconds: 10),
              const Duration(seconds: 30),
              const Duration(seconds: 0),
              const Duration(seconds: 0, minutes: 5),
              const Duration(seconds: 0, minutes: 30),
              const Duration(seconds: 0),
              const Duration(seconds: 0, minutes: 0, hours: 3),
              const Duration(seconds: 0, minutes: 0, hours: 24),
            ].map((duration) => duration == Duration.zero
                ? const Divider(
                    height: 0,
                    indent: 16.0,
                    endIndent: 16.0,
                  )
                : ListTile(
                    onTap: () {
                      Navigator.of(context).pop(duration);
                    },
                    title: Text(duration.toHms()),
                  )),
            const Divider(
              height: 0.0,
              indent: 16.0,
              endIndent: 16.0,
            ),
            ListTile(
              title: const Text('Custom time'),
              onTap: () {
                Navigator.of(context).pop(Duration.zero);
              },
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }
}

class _SleepingProgressIndicator extends HookConsumerWidget {
  const _SleepingProgressIndicator({
    Key? key,
    required this.status,
  }) : super(key: key);

  final PiholeStatusSleeping status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final remaining = status.duration - now.difference(status.start);

    return Stack(
      alignment: Alignment.center,
      children: [
        LoadingIndicator(
          size: 18.0,
          color: Theme.of(context).dividerColor,
          strokeWidth: 2.0,
          value: 1.0,
        ),
        if (remaining.inSeconds > 0 && remaining.inMinutes <= 5) ...[
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: remaining,
            builder: (context, value, _) => LoadingIndicator(
              size: 18.0,
              color: Theme.of(context).colorScheme.onSecondary,
              strokeWidth: 2.0,
              value: value,
            ),
          )
        ],
      ],
    );
  }
}

class _StatusIcon extends HookConsumerWidget {
  const _StatusIcon({
    Key? key,
    this.animate = true,
  }) : super(key: key);

  final bool animate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ping = ref.watch(PingNotifier.provider);
    final status = ping.status;
    final isLoading = ping.loading;

    return _Tooltip(
      message: status.maybeWhen(
        sleeping: (duration, start) =>
            'Sleeping until ${start.add(duration).hms}',
        orElse: () => '',
      ),
      child: AnimatedStack(
          children: [
            LoadingIndicator(
              size: 18.0,
              color: Theme.of(context).colorScheme.onSecondary,
              strokeWidth: 2.0,
            ),
            const Icon(KIcons.disablePihole),
            const Icon(KIcons.enablePihole),
            status.maybeMap(
                sleeping: (status) => _SleepingProgressIndicator(
                    status: status.copyWith(start: status.start)),
                orElse: () => Container()),
            _Tooltip(
                message: Formatting.errorToDescription(ping.error ?? ''),
                child: const Icon(KIcons.disconnected)),
          ],
          active: isLoading
              ? 0
              : ping.error != null
                  ? 4
                  : status.map(
                      enabled: (_) => 1,
                      disabled: (_) => 2,
                      sleeping: (_) => 3,
                    )),
    );
  }
}

class _Tooltip extends StatelessWidget {
  const _Tooltip({
    Key? key,
    required this.message,
    required this.child,
  }) : super(key: key);

  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      // decoration: BoxDecoration(
      //   color: Theme.of(context).colorScheme.background,
      //   borderRadius: BorderRadius.circular(20.0),
      // ),
      // textStyle: Theme.of(context)
      //     .textTheme
      //     .caption
      //     ?.copyWith(color: Theme.of(context).colorScheme.onBackground),
      message: message,
      preferBelow: false,
      child: child,
    );
  }
}
