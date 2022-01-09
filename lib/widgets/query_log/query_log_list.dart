import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/services/api_service.dart';
import 'package:flutterhole/widgets/layout/animated_list.dart';
import 'package:flutterhole/widgets/layout/animations.dart';
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
    this.max = 20,
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
    final hideList = useState(true);
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
      k.currentState?.removeItem(
          index,
          (context, animation) => AnimatedSizeFade(
              animation: animation,
              child: _Tile(
                item: item,
                onHide: () {},
              )),
          duration: duration);
      data.value = [...data.value]..removeAt(index);
      deleted.value = [...deleted.value, item];
    }

    useValueChanged<AsyncValue, List<QueryItem>>(
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

          hideList.value = false;
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
        if (data.value.isEmpty) ...[
          const Center(child: Text('No queries found.'))
        ],
        if (data.value.isNotEmpty) ...[
          animate
              ? AnimatedList(
                  key: k,
                  initialItemCount: data.value.length,
                  itemBuilder: (context, index, animation) {
                    var item = data.value.elementAt(index);
                    return AnimatedSizeFade(
                        animation: animation,
                        child: _Tile(
                          item: item,
                          onTap: () {
                            // final index = data.value.length - 1;
                            // deleteAtIndex(index, data.value.elementAt(index));
                            // print(
                            //     'delete ${data.value.elementAt(index).domain}');
                            // deleteAtIndex(index, data.value.elementAt(index));
                          },
                          onHide: () => deleteAtIndex(index, item),
                        ));
                  },
                )
              : _ListBuilder(
                  items: data.value,
                  onTap: (index) {},
                ),
        ],
        AnimatedColorFader(
          show: hideList.value,
          // color: Colors.orange,
          // child: Text('hi'),
        ),
        if (error != null) ...[
          CenteredErrorMessage(
            error,
            message: 'Something went wrong.',
          )
        ],
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
    this.onHide,
  }) : super(key: key);

  final QueryItem item;
  final VoidCallback? onTap;
  final VoidCallback? onHide;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: Key(item.toString()),
      // startActionPane: ActionPane(
      //   motion: BehindMotion(),
      //   children: [
      //     SlidableStyleAction(
      //       onPressed: (context) {},
      //       backgroundColor: Theme.of(context).colorScheme.primary,
      //       label: 'Hide',
      //       labelStyle:
      //           TextStyle(color: Theme.of(context).colorScheme.onPrimary),
      //       icon: KIcons.delete,
      //     ),
      //     SlidableStyleAction(
      //       onPressed: (context) {},
      //       backgroundColor: Theme.of(context).colorScheme.secondary,
      //       label: 'Show',
      //       labelStyle:
      //           TextStyle(color: Theme.of(context).colorScheme.onSecondary),
      //       icon: KIcons.delete,
      //     ),
      //   ],
      // ),
      endActionPane: onHide != null
          ? ActionPane(
              motion: const BehindMotion(),
              extentRatio: .2,
              children: [
                SlidableStyleAction(
                  onPressed: (context) {
                    // deleteAtIndex(index, item);
                    onHide!();
                  },
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  label: 'Hide',
                  labelStyle:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                  icon: KIcons.toggleInvisible,
                  autoClose: false,
                ),
              ],
            )
          : null,
      child: ListTile(
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
      ),
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

class SlidableStyleAction extends StatelessWidget {
  const SlidableStyleAction({
    Key? key,
    this.flex = 1,
    this.backgroundColor = Colors.purple,
    this.foregroundColor,
    this.autoClose = true,
    required this.onPressed,
    this.icon,
    this.spacing = 4,
    this.label,
    this.labelStyle,
  })  : assert(flex > 0),
        assert(icon != null || label != null),
        super(key: key);

  /// {@macro slidable.actions.flex}
  final int flex;

  /// {@macro slidable.actions.backgroundColor}
  final Color backgroundColor;

  /// {@macro slidable.actions.foregroundColor}
  final Color? foregroundColor;

  /// {@macro slidable.actions.autoClose}
  final bool autoClose;

  /// {@macro slidable.actions.onPressed}
  final SlidableActionCallback? onPressed;

  /// An icon to display above the [label].
  final IconData? icon;

  /// The space between [icon] and [label] if both set.
  ///
  /// Defaults to 4.
  final double spacing;

  /// A label to display below the [icon].
  final String? label;

  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    if (icon != null) {
      children.add(
        Icon(icon),
      );
    }

    if (label != null) {
      if (children.isNotEmpty) {
        children.add(
          SizedBox(height: spacing),
        );
      }

      children.add(
        Text(
          label!,
          overflow: TextOverflow.ellipsis,
          style: labelStyle,
        ),
      );
    }

    final child = children.length == 1
        ? children.first
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...children.map(
                (child) => Flexible(
                  child: child,
                ),
              )
            ],
          );

    return CustomSlidableAction(
      onPressed: onPressed,
      autoClose: autoClose,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      flex: flex,
      child: child,
    );
  }
}
