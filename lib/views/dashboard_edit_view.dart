import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/views/base_view.dart';
import 'package:flutterhole/views/settings_view.dart';
import 'package:flutterhole/widgets/dashboard/dashboard_grid.dart';
import 'package:flutterhole/widgets/layout/dialogs.dart';
import 'package:flutterhole/widgets/layout/responsiveness.dart';
import 'package:flutterhole/widgets/ui/buttons.dart';
import 'package:flutterhole/widgets/ui/snackbars.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class DashboardEditView extends HookConsumerWidget {
  const DashboardEditView({
    Key? key,
  }) : super(key: key);

  static final Function _eq = const ListEquality().equals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pi = ref.watch(piProvider);
    final entries = useState(pi.dashboard);

    void saveDashboard() {
      ref.read(UserPreferencesNotifier.provider.notifier).savePihole(
          oldValue: pi, newValue: pi.copyWith(dashboard: entries.value));
      highlightSnackBar(context, const Text('Dashboard saved.'));
    }

    return WillPopScope(
      onWillPop: () async {
        if (_eq(pi.dashboard, entries.value)) return true;

        final save = await showConfirmationDialog(
          context,
          title: 'Save changes?',
          okLabel: 'Save',
          cancelLabel: 'Discard',
        );

        if (save == true) {
          saveDashboard();
          return true;
        }

        return save == false;
      },
      child: BaseView(
        child: LeftRightScaffold(
          title: Text(
            '${pi.title} Dashboard',
            overflow: TextOverflow.fade,
          ),
          actions: [
            PopupMenuButton<String>(
              tooltip: '',
              onSelected: (selected) {
                if (selected == 'Enable all') {
                  entries.value = entries.value
                      .map((e) => e.copyWith(enabled: true))
                      .toList();
                } else if (selected == 'Disable all') {
                  entries.value = entries.value
                      .map((e) => e.copyWith(enabled: false))
                      .toList();
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
            SaveIconButton(onPressed: () {
              if (!_eq(pi.dashboard, entries.value)) {
                saveDashboard();
              }

              Navigator.of(context).pop();
            }
                // Navigator.of(context).pop();
                ),
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

              final list =
                  List<DashboardEntry>.from(entries.value, growable: true);
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
        ),
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
              message: entry.enabled ? 'Disable' : 'Enable',
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
