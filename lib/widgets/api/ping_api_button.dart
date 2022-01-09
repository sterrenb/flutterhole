import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/services/api_service.dart';
import 'package:flutterhole/widgets/layout/animations.dart';
import 'package:flutterhole/widgets/layout/centered_leading.dart';
import 'package:flutterhole/widgets/layout/loading_indicator.dart';
import 'package:flutterhole/widgets/layout/responsiveness.dart';
import 'package:flutterhole/widgets/ui/dialogs.dart';
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
    final status = useState(const PiholeStatus.disabled());
    final isLoading = useState(false);

    Future<void> sleep(Duration duration) async {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 500));
      final now = DateTime.now();
      status.value = PiholeStatus.sleeping(duration, now);
      highlightSnackBar(
        context,
        content: Text('Sleeping for ${duration.toHms()}.'),
        undo: () {
          isLoading.value = false;
          status.value = const PiholeStatus.enabled();
        },
      );
      isLoading.value = false;
      Future.delayed(duration).then((_) {
        if (status.value is PiholeStatusSleeping) {
          isLoading.value = false;
          status.value = const PiholeStatus.enabled();
        }
      });
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
        onLongPress: showSleepDialog,
        child: FloatingActionButton.extended(
          extendedTextStyle: Theme.of(context)
              .textTheme
              .subtitle1
              ?.copyWith(color: Theme.of(context).colorScheme.secondary),
          onPressed: () async {
            if (isLoading.value) return;
            isLoading.value = true;
            await Future.delayed(const Duration(milliseconds: 500));
            status.value = status.value.map(
              enabled: (_) => const PiholeStatus.disabled(),
              disabled: (_) => const PiholeStatus.enabled(),
              sleeping: (_) => const PiholeStatus.enabled(),
            );
            isLoading.value = false;
          },
          icon: _StatusIcon(
            status.value,
            isLoading: isLoading.value,
          ),
          label: DefaultAnimatedSize(
            child: AnimatedStack(
              children: const [
                Text('Disable'),
                Text('Enable'),
                Text('Enable'),
              ],
              active: status.value.when(
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

    return Tooltip(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(20.0),
      ),
      textStyle: Theme.of(context)
          .textTheme
          .caption
          ?.copyWith(color: Theme.of(context).colorScheme.onBackground),
      message: status.whenOrNull(
              sleeping: (duration, start) =>
                  'Sleeping until ${start.add(duration).hms}') ??
          '',
      preferBelow: false,
      child: Stack(
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
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon(
    this.status, {
    Key? key,
    required this.isLoading,
    this.animate = true,
  }) : super(key: key);

  final PiholeStatus status;
  final bool isLoading;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return AnimatedStack(
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
        ],
        active: isLoading
            ? 0
            : status.map(
                enabled: (_) => 1,
                disabled: (_) => 2,
                sleeping: (_) => 3,
              ));
  }
}
