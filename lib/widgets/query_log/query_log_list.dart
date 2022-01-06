import 'package:flutter/material.dart';
import 'package:flutterhole/services/api_service.dart';
import 'package:flutterhole/widgets/layout/loading_indicator.dart';
import 'package:flutterhole/widgets/settings/extensions.dart';
import 'package:flutterhole/widgets/ui/cache.dart';
import 'package:flutterhole/widgets/ui/dialogs.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pihole_api/pihole_api.dart';

class QueryLogList extends HookConsumerWidget {
  const QueryLogList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CacheBuilder<List<QueryItem>>(
      provider: activeQueryItemsProvider,
      builder: (context, data, isLoading, error) {
        return Stack(
          alignment: Alignment.topRight,
          children: [
            Positioned(
              left: 8.0,
              top: 8.0,
              child: TextButton(
                  onPressed: () {
                    ref.refreshQueryItems();
                  },
                  child: const Text('Refresh')),
            ),
            ...[CenteredErrorMessage(error ?? 'hi')],
            AnimatedLoadingErrorIndicatorIcon(
              isLoading: isLoading,
              error: error,
              mouseCursor: SystemMouseCursors.basic,
            ),
          ],
        );
      },
    );
  }
}
