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

    void onSleep() async {
      final now = TimeOfDay.now();
      final result = await showModal<TimeOfDay>(
          context: context,
          builder: (context) {
            return TimePickerDialog(
              initialTime: now,
              confirmText: 'Sleep'.toUpperCase(),
              helpText: 'Sleep until...'.toUpperCase(),
            );
          });

      if (result == null || result == now) return;

      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 500));
      status.value =
          PiholeStatus.sleeping(result.absoluteDuration(), DateTime.now());
      isLoading.value = false;
    }

    return BreakpointBuilder(builder: (context, isBig) {
      return GestureDetector(
        onLongPress: onSleep,
        child: Tooltip(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: BorderRadius.circular(20.0),
          ),
          textStyle: Theme.of(context)
              .textTheme
              .caption
              ?.copyWith(color: Theme.of(context).colorScheme.onBackground),
          message: status.value.whenOrNull(
                  sleeping: (duration, start) =>
                      'Sleeping until ${start.add(duration).hms}') ??
              '',
          preferBelow: false,
          child: FloatingActionButton.extended(
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
                  Text('Wake up'),
                ],
                active: status.value.when(
                  enabled: () => 0,
                  disabled: () => 1,
                  sleeping: (duration, start) => 2,
                ),
              ),
            ),
          ),
        ),
      );
    });
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
    final remaining =
        useState(status.duration - DateTime.now().difference(status.start));
    return Stack(
      alignment: Alignment.center,
      children: [
        LoadingIndicator(
          size: 18.0,
          color: Theme.of(context).dividerColor,
          strokeWidth: 2.0,
          value: 1.0,
        ),
        if (remaining.value.inSeconds > 0) ...[
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: remaining.value,
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
              orElse: () => const Text('?')),
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
