import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/services/api_service.dart';
import 'package:flutterhole/widgets/layout/animated_list.dart';
import 'package:flutterhole/widgets/layout/grids.dart';
import 'package:flutterhole/widgets/layout/loading_indicator.dart';
import 'package:flutterhole/widgets/ui/buttons.dart';
import 'package:flutterhole/widgets/ui/dialogs.dart';
import 'package:flutterhole/widgets/ui/time.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pihole_api/pihole_api.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class QueryLogList extends HookConsumerWidget {
  const QueryLogList({
    Key? key,
    this.max = 10,
    this.animate = true,
  }) : super(key: key);

  final int max;
  final bool animate;

  static const Duration duration = kThemeAnimationDuration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final k = useState(GlobalKey<AnimatedListState>()).value;
    final data = useState(<QueryItem>[]);
    final deleted = useState(<QueryItem>[]);
    final queries = ref.watch(activeQueryItemsProvider);
    final isLoading = queries.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    final error = queries.whenOrNull(error: (e, s) => e);

    void insertAtIndex(int index, QueryItem item) async {
      k.currentState?.insertItem(index, duration: duration);
    }

    void deleteAtIndex(int index, QueryItem item) async {
      print('deleting ${item.domain} @ $index, currently ${data.value.length}');
      k.currentState?.removeItem(
          index,
          (context, animation) => DefaultAnimatedSize(
              animation: animation,
              child: _Tile(
                item: item,
              )),
          duration: duration);
      data.value = [...data.value]..removeAt(index);
      deleted.value = [...deleted.value, item];
    }

    final allQueries = useValueChanged<AsyncValue, List<QueryItem>>(
      queries,
      (AsyncValue oldQueries, oldResult) {
        final newResult = queries.whenOrNull(data: (update) => update);

        if (newResult != null) {
          final difference = [...newResult]
            ..removeWhere((element) => deleted.value.contains(element))
            ..removeWhere((element) => data.value.contains(element));

          data.value = [
            ...difference,
            ...data.value,
          ];

          for (QueryItem element in difference) {
            insertAtIndex(0, element);
          }
        }
        return newResult ?? oldResult;
      },
    );

    void deleteLast() {
      final index = data.value.length - 1;
      deleteAtIndex(index, data.value.elementAt(index));
    }

    useEffect(() {
      final deleteCount = data.value.length - max;
      for (int i = 0; i < deleteCount; i++) {
        deleteLast();
      }
    }, [data.value]);

    return Stack(
      alignment: Alignment.topRight,
      children: [
        Text('allQueries: ${allQueries?.length}'),
        if (data.value.isEmpty) ...[
          const Center(child: Text('No queries found.'))
        ],
        if (data.value.isNotEmpty) ...[
          animate
              ? AnimatedList(
                  key: k,
                  initialItemCount: data.value.length,
                  itemBuilder: (context, index, animation) {
                    return DefaultAnimatedSize(
                        animation: animation,
                        child: _Tile(
                          item: data.value.elementAt(index),
                          onTap: () {
                            // final index = data.value.length - 1;
                            // deleteAtIndex(index, data.value.elementAt(index));
                            // print(
                            //     'delete ${data.value.elementAt(index).domain}');
                            // deleteAtIndex(index, data.value.elementAt(index));
                          },
                        ));
                  },
                )
              : _ListBuilder(
                  items: data.value,
                  onTap: (index) {},
                ),
        ],
        if (error != null) ...[CenteredErrorMessage(error)],
        Positioned(
          right: 0,
          child: AnimatedLoadingErrorIndicatorIcon(
            isLoading: isLoading,
            // isLoading: true,
            error: error,
            mouseCursor: SystemMouseCursors.basic,
          ),
        ),
      ],
    );
  }
}

class _ListBuilder extends StatelessWidget {
  const _ListBuilder({
    Key? key,
    required this.items,
    required this.onTap,
  }) : super(key: key);

  final List<QueryItem> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _Tile(
          item: items.elementAt(index),
          onTap: () => onTap(index),
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    Key? key,
    required this.item,
    this.onTap,
  }) : super(key: key);

  final QueryItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // dense: true,
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
      onTap: onTap,
      onLongPress: () {
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
