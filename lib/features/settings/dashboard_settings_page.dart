import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/entities/settings_entities.dart';
import 'package:flutterhole_web/features/grid/grid_layout.dart';
import 'package:flutterhole_web/features/models/settings_models.dart';
import 'package:flutterhole_web/features/settings/single_pi_page.dart';
import 'package:flutterhole_web/features/settings/themes.dart';

class DashboardSettingsPage extends HookWidget {
  const DashboardSettingsPage({
    Key? key,
    required this.initial,
    required this.onSave,
  }) : super(key: key);

  final DashboardSettings initial;
  final ValueChanged<DashboardSettings> onSave;

  @override
  Widget build(BuildContext context) {
    final unselectedList = DashboardTileConstraints.defaults.keys
        .where((id) => !initial.keys.contains(id))
        .map<DashboardEntry>((id) {
      return DashboardEntry(
          id: id,
          enabled: false,
          constraints: DashboardTileConstraints.defaults[id]!);
    }).toList();

    final localList = useState([
      ...initial.entries,
      ...unselectedList,
    ]);

    // print(
    //     'available: ${localList.value.length} / ${staggeredTile.keys.length}');
    // print('unselected: ${unselectedList.length}');
    // print(unselectedList.map((e) => e.id));

    return ActivePiTheme(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Select tiles'),
          actions: [
            TextSaveButton(
              onPressed: () {
                context.router.pop();
                onSave(DashboardSettings(entries: localList.value));
              },
            ),
          ],
        ),
        body: ReorderableListView(
            physics: const BouncingScrollPhysics(),
            buildDefaultDragHandles: true,
            children: <Widget>[
              for (int index = 0; index < localList.value.length; index++)
                _SelectTile(
                  key: Key('$index'),
                  index: index,
                  title: localList.value
                      .elementAt(index)
                      .id
                      .toString()
                      .split('.')
                      .last,
                  entry: localList.value.elementAt(index),
                  onTap: () {
                    final l = List<DashboardEntry>.from(localList.value);
                    l[index] = l
                        .elementAt(index)
                        .copyWith(enabled: !l.elementAt(index).enabled);
                    localList.value = l;
                  },
                )
            ],
            onReorder: (oldIndex, newIndex) {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }

              final list =
                  List<DashboardEntry>.from(localList.value, growable: true);
              final item = list.removeAt(oldIndex);
              list.insert(newIndex, item);
              localList.value = list;
            }),
      ),
    );
  }
}

extension DashboardIDI on DashboardID {
  IconData get iconData {
    switch (this) {
      case DashboardID.versions:
        return KIcons.appVersion;
      case DashboardID.totalQueries:
        return KIcons.totalQueries;
      case DashboardID.queriesBlocked:
        return KIcons.queriesBlocked;
      case DashboardID.percentBlocked:
        return KIcons.percentBlocked;
      case DashboardID.domainsOnBlocklist:
        return KIcons.domainsOnBlocklist;
      case DashboardID.queriesBarChart:
        return KIcons.queriesOverTime;
      case DashboardID.clientActivityBarChart:
        return KIcons.clientActivity;
      case DashboardID.temperature:
        return KIcons.temperatureReading;
      case DashboardID.memory:
        return KIcons.memoryUsage;
      case DashboardID.queryTypes:
        return KIcons.memoryUsage;
      case DashboardID.forwardDestinations:
        return KIcons.memoryUsage;
      case DashboardID.topPermittedDomains:
        return KIcons.domainsPermittedTile;
      case DashboardID.topBlockedDomains:
        return KIcons.domainsBlockedTile;
      case DashboardID.selectTiles:
        return KIcons.selectDashboardTiles;
      case DashboardID.logs:
        return KIcons.debugLogs;
      case DashboardID.tempTile:
        return KIcons.add; // TODO
    }
  }
}

class _SelectTile extends StatelessWidget {
  const _SelectTile({
    Key? key,
    required this.index,
    required this.title,
    required this.entry,
    required this.onTap,
  }) : super(key: key);
  final int index;
  final String title;
  final DashboardEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ReorderableDelayedDragStartListener(
      index: index,
      child: Column(
        children: [
          const Divider(height: 0),
          ListTile(
            onTap: onTap,
            title: Text(
              title,
              style: TextStyle(
                  color:
                      entry.enabled ? null : Theme.of(context).disabledColor),
            ),
            leading: GridIcon(
              entry.id.iconData,
              isDark: true,
            ),
            trailing: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message: 'Toggle visibility',
                  child: Checkbox(
                    value: entry.enabled,
                    onChanged: (_) => onTap(),
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
          const Divider(height: 0),
        ],
      ),
    );
  }
}
