import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/services/api_service.dart';
import 'package:flutterhole/widgets/developer/dev_widget.dart';
import 'package:flutterhole/widgets/layout/animations.dart';
import 'package:flutterhole/widgets/layout/grids.dart';
import 'package:flutterhole/widgets/layout/loading_indicator.dart';
import 'package:flutterhole/widgets/settings/extensions.dart';
import 'package:flutterhole/widgets/ui/buttons.dart';
import 'package:flutterhole/widgets/ui/cache.dart';
import 'package:flutterhole/widgets/ui/dialogs.dart';
import 'package:flutterhole/widgets/ui/time.dart';
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
            // Container(
            //   color: Colors.purple,
            // ),
            // AnimatedFader(
            //     child: data != null && data.isEmpty
            //         ? const Center(child: Text('No queries found.'))
            //         : Container(
            //             color: Theme.of(context).scaffoldBackgroundColor,
            //           )),
            // if (data != null) ...[
            //   Container(
            //     color: Theme.of(context).primaryColor,
            //   ),
            // ],
            if (data != null && data.isEmpty) ...[
              const Center(child: Text('No queries found.'))
            ],
            if (data != null && data.isNotEmpty) ...[
              ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return _Tile(
                    item: data.elementAt(index),
                  );
                },
              )
            ],
            AnimatedColorFader(
              show: data == null || (data.isEmpty && isLoading),
            ),
            DevWidget(
                child: Positioned(
              left: 8.0,
              top: 8.0,
              child: Card(
                child: TextButton(
                    onPressed: () {
                      ref.refreshQueryItems();
                    },
                    child: const Text('Refresh')),
              ),
            )),
            if (data == null && error != null) ...[CenteredErrorMessage(error)],
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

class _Tile extends StatelessWidget {
  const _Tile({Key? key, required this.item}) : super(key: key);
  final QueryItem item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(
        item.domain,
      ),
      subtitle: Text(
        item.queryStatus.description,
      ),
      leading: Icon(
        item.queryStatus.iconData,
        color: item.queryStatus.color,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            item.timestamp.hms,
            style: Theme.of(context).textTheme.caption,
          ),
          DifferenceText(item.timestamp),
        ],
      ),
      onTap: () {
        showScrollableConfirmationDialog(
          context,
          contentPadding: EdgeInsets.zero,
          canCancel: false,
          // title: item.domain,
          body: QueryItemDialog(item: item),
        );
      },
    );
  }
}

class QueryItemDialog extends StatelessWidget {
  const QueryItemDialog({
    Key? key,
    required this.item,
  }) : super(key: key);

  final QueryItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 16.0,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 400.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Domain'),
              leading: const Icon(KIcons.queryDomain),
              subtitle: SelectableText(item.domain),
            ),
            ListTile(
              title: const Text('Status'),
              leading: Icon(item.queryStatus.iconData),
              subtitle: Text(item.queryStatus.description),
            ),
            ListTile(
              title: const Text('Client'),
              leading: const Icon(KIcons.queryClient),
              subtitle: SelectableText(item.clientName),
            ),
            ListTile(
              title: const Text('Timestamp'),
              leading: const Icon(KIcons.queryTimestamp),
              subtitle: Text(item.timestamp.full),
            ),
            ListTile(
              title: const Text('Type'),
              leading: const Icon(KIcons.queryType),
              subtitle: Text(item.queryType),
            ),
            ListTile(
              title: const Text('DNSSEC'),
              leading: const Icon(KIcons.queryDnsSec),
              subtitle: Text(Formatting.enumToString(item.dnsSecStatus)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AppWrap(children: [
                UrlOutlinedButton(url: item.domain),
              ]),
            )
          ],
        ),
      ),
    );
  }
}
