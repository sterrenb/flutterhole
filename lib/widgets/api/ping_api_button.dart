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
    final status = useState(PiholeStatus.enabled());
    final isLoading = useState(false);

    void onTap() async {
      if (isLoading.value) return;
      isLoading.value = true;
      await Future.delayed(Duration(milliseconds: 500));
      status.value = status.value.map(
        enabled: (_) => PiholeStatus.disabled(),
        disabled: (_) => PiholeStatus.enabled(),
        sleeping: (_) => PiholeStatus.enabled(),
      );
      isLoading.value = false;
    }

    final label = status.value.when(
      enabled: () => 'Disable',
      disabled: () => 'Enable',
      sleeping: (duration, start) => 'Enable',
    );

    return BreakpointBuilder(builder: (context, isBig) {
      return isBig || true
          ? FloatingActionButton.extended(
              onPressed: onTap,
              icon: Stack(
                children: [
                  // Icon(KIcons.disablePihole),
                  _StatusIcon(
                    status.value,
                    isLoading: isLoading.value,
                  ),
                ],
              ),
              label: DefaultAnimatedSize(
                child: Text(label),
                // child: AnimatedStack(
                //   children: [
                //     Text('Disable'),
                //     Text('Enable'),
                //     Text('Enable'),
                //   ],
                //   active: status.value.when(
                //     enabled: () => 0,
                //     disabled: () => 1,
                //     sleeping: (duration, start) => 2,
                //   ),
                // ),
              ),
            )
          : FloatingActionButton(
              onPressed: onTap,
              child: _StatusIcon(
                status.value,
                isLoading: isLoading.value,
              ),
            );
    });
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
    return animate
        ? AnimatedStack(
            children: [
                LoadingIndicator(
                  size: 18.0,
                  color: Theme.of(context).colorScheme.onSecondary,
                  strokeWidth: 2.0,
                ),
                Icon(KIcons.disablePihole),
                Icon(KIcons.enablePihole),
                Icon(KIcons.enablePihole),
              ],
            active: isLoading
                ? 0
                : status.map(
                    enabled: (_) => 1,
                    disabled: (_) => 2,
                    sleeping: (_) => 3,
                  ))
        : Icon(status.map(
            enabled: (_) => KIcons.disablePihole,
            disabled: (_) => KIcons.enablePihole,
            sleeping: (_) => KIcons.enablePihole,
          ));
  }
}
