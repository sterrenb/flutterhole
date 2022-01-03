import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/services/api_service.dart';
import 'package:flutterhole/widgets/layout/animations.dart';
import 'package:flutterhole/widgets/layout/centered_leading.dart';
import 'package:flutterhole/widgets/layout/dialogs.dart';
import 'package:flutterhole/widgets/layout/loading_indicator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
      title: const Text("Pi-hole status"),
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
