import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/views/settings_view.dart';
import 'package:flutterhole/widgets/dashboard/dashboard_grid.dart';
import 'package:flutterhole/widgets/layout/responsiveness.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class DashboardEditView extends HookConsumerWidget {
  const DashboardEditView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pi = ref.watch(activePiProvider);
    final entries = useState(pi.dashboard);

    return LeftRightScaffold(
      title: Text(
        'Select tiles for ${pi.title}',
        overflow: TextOverflow.fade,
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (selected) {
            if (selected == 'Enable all') {
              entries.value =
                  entries.value.map((e) => e.copyWith(enabled: true)).toList();
            } else if (selected == 'Disable all') {
              entries.value =
                  entries.value.map((e) => e.copyWith(enabled: false)).toList();
            } else if (selected == 'Use defaults') {
              entries.value = DashboardEntry.all;
            }
          },
          itemBuilder: (context) => [
            'Enable all',
            'Disable all',
            'Use defaults',
          ]
              .map((choice) =>
                  PopupMenuItem<String>(value: choice, child: Text(choice)))
              .toList(),
        ),
        IconButton(
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsView()));
            },
            icon: const Icon(KIcons.settings)),
      ],
      tabs: const [
        Tab(icon: Icon(KIcons.tileList)),
        Tab(icon: Icon(KIcons.dashboard)),
      ],
      left: ReorderableListView.builder(
        itemCount: entries.value.length,
        itemBuilder: (context, index) {
          final entry = entries.value.elementAt(index);
          return _Tile(
            key: Key(entry.id.name),
            index: index,
            entry: entry,
            onToggle: () {
              final list = List<DashboardEntry>.from(entries.value);
              list[index] = list
                  .elementAt(index)
                  .copyWith(enabled: !list.elementAt(index).enabled);
              entries.value = list;
            },
          );
        },
        onReorder: (from, to) {
          if (from < to) {
            to -= 1;
          }

          final list = List<DashboardEntry>.from(entries.value, growable: true);
          final item = list.removeAt(from);
          list.insert(to, item);
          entries.value = list;
        },
      ),
      right: Container(
        color: Theme.of(context).colorScheme.secondary.withOpacity(.1),
        child: SingleChildScrollView(
            child: DashboardGrid(
          entries: entries.value,
        )),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    Key? key,
    required this.index,
    required this.entry,
    required this.onToggle,
  }) : super(key: key);

  final int index;
  final DashboardEntry entry;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return ReorderableDelayedDragStartListener(
      index: index,
      child: ListTile(
        title: Text(entry.id.toReadable()),
        onTap: onToggle,
        trailing: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              entry.constraints.when(
                count: (cross, main) => '$cross x $main',
                extent: (cross, extent) => '$cross x ${extent.toInt()}px',
                fit: (cross) => '$cross x fit',
              ),
              style: Theme.of(context)
                  .textTheme
                  .caption
                  ?.merge(GoogleFonts.firaMono()),
            ),
            Tooltip(
              message: (entry.enabled ? 'Disable' : 'Enable') + ' visibility',
              child: Checkbox(
                value: entry.enabled,
                onChanged: (_) {
                  onToggle();
                },
              ),
            ),
            ReorderableDragStartListener(
              index: index,
              child: const IconButton(
                onPressed: null,
                icon: Icon(Icons.drag_handle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
