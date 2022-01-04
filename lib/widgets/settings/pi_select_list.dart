import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/views/single_pi_edit_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PiSelectList extends HookConsumerWidget {
  const PiSelectList({
    Key? key,
    this.shrinkWrap = false,
  }) : super(key: key);

  final bool shrinkWrap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final piholes = ref.watch(allPiholesProvider);
    return ReorderableListView.builder(
      shrinkWrap: shrinkWrap,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: piholes.length,
      onReorder: (from, to) {
        if (from < to) {
          to -= 1;
        }

        final list = List<Pi>.from(piholes, growable: true);
        final item = list.removeAt(from);
        list.insert(to, item);
        ref.read(UserPreferencesNotifier.provider.notifier).savePiholes(list);
      },
      itemBuilder: (context, index) {
        final pi = piholes.elementAt(index);
        return _Tile(
          key: Key(index.toString()),
          pi: pi,
          index: index,
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ProviderScope(overrides: [
                piProvider.overrideWithValue(pi),
              ], child: const SinglePiEditView()),
              // fullscreenDialog: true,
            ));
          },
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    Key? key,
    required this.pi,
    required this.index,
    this.onTap,
  }) : super(key: key);

  final Pi pi;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ReorderableDelayedDragStartListener(
      index: index,
      child: ListTile(
        minVerticalPadding: 16.0,
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
