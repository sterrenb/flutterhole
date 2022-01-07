import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/services/web_service.dart';
import 'package:flutterhole/views/single_pi_edit_view.dart';
import 'package:flutterhole/widgets/settings/extensions.dart';
import 'package:flutterhole/widgets/ui/dialogs.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PiSelectList extends HookConsumerWidget {
  const PiSelectList({
    Key? key,
    this.shrinkWrap = false,
    this.max,
  }) : super(key: key);

  final bool shrinkWrap;
  final int? max;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(piProvider);
    final piholes = ref.watch(allPiholesProvider);

    return ReorderableListView.builder(
      shrinkWrap: shrinkWrap,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: piholes.length.clamp(1, max ?? piholes.length),
      onReorder: (from, to) {
        ref
            .read(UserPreferencesNotifier.provider.notifier)
            .reorderPiholes(from, to);
      },
      itemBuilder: (context, index) {
        final pi = piholes.elementAt(index);
        return _Tile(
          key: Key(index.toString()),
          pi: pi,
          selected: pi == active,
          index: index,
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ProviderScope(overrides: [
                piProvider.overrideWithValue(pi),
              ], child: const SinglePiEditView(isNew: false)),
              // fullscreenDialog: true,
            ));
          },
          onDelete: piholes.length > 1
              ? () {
                  // ref
                  //     .read(UserPreferencesNotifier.provider.notifier)
                  //     .deletePihole(pi);
                  ref.deletePihole(context, pi);
                }
              : null,
        );
      },
    );
  }
}

class _Tile extends HookConsumerWidget {
  const _Tile({
    Key? key,
    required this.pi,
    required this.index,
    required this.selected,
    this.onTap,
    this.onDelete,
  }) : super(key: key);

  final Pi pi;
  final int index;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ReorderableDelayedDragStartListener(
      index: index,
      child: ListTile(
        // minVerticalPadding: 16.0,
        leading: Icon(
          KIcons.selected,
          color: selected
              ? Theme.of(context).colorScheme.secondary
              : Colors.transparent,
        ),
        title: Text(pi.title),
        subtitle: Text(
          pi.baseUrl,
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        trailing: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            // UrlOutlinedButton(
            //   url: pi.baseUrl + pi.adminHome,
            //   text: pi.baseUrl
            //       .replaceFirst('https://', '')
            //       .replaceFirst('http://', ''),
            // ),
            PopupMenuButton<String>(
              tooltip: '',
              onSelected: (String value) {
                if (value == 'Delete') {
                  showDeleteConfirmationDialog(context, 'Delete ${pi.title}?')
                      .then((isDeleted) {
                    if (isDeleted ?? false) {
                      if (onDelete != null) onDelete!();
                      // Navigator.of(context).pop();
                    }
                  });
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: !selected,
                  onTap: () {
                    ref
                        .read(UserPreferencesNotifier.provider.notifier)
                        .selectPihole(pi);
                  },
                  child: const Text('Select'),
                ),
                PopupMenuItem(
                  onTap: () {
                    WebService.launchUrlInBrowser(Formatting.piToAdminUrl(pi));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Open in browser'),
                      Tooltip(
                          message: Formatting.piToAdminUrl(pi),
                          child: const Icon(KIcons.openUrl)),
                    ],
                  ),
                ),
                if (onDelete != null) ...[
                  PopupMenuItem(
                    value: 'Delete',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Delete',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        Icon(
                          KIcons.delete,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ],
                    ),
                  )
                ],
              ],
            ),
            ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
