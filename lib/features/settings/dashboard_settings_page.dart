import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/features/grid/grid_layout.dart';
import 'package:flutterhole_web/features/home/dashboard_grid.dart';
import 'package:flutterhole_web/features/settings/single_pi_page.dart';

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
    final unselectedList = staggeredTile.keys
        .where((id) => !initial.keys.contains(id))
        .map<DashboardEntry>((id) {
      print('returning extra tile for $id');
      return DashboardEntry(
        id: id,
        enabled: false,
      );
    }).toList();

    final localList = useState([
      ...initial.entries,
      ...unselectedList,
    ]);

    print(
        'available: ${localList.value.length} / ${staggeredTile.keys.length}');
    print('unselected: ${unselectedList.length}');
    print(unselectedList.map((e) => e.id));

    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        // controller: controller,
        title: Text('Select tiles'),
        actions: [
          TextSaveButton(
            onPressed: () {
              context.router.pop();
              onSave(DashboardSettings(entries: localList.value));
            },
          ),
          // IconButton(
          //     tooltip: 'Reset to default',
          //     onPressed: () {
          //       // localList.value = DashboardSettings.initial().entries;
          //       // context.read(dashboardProvider).state =
          //       //     _dashboardProviderDefault;
          //     },
          //     icon: Icon(
          //       Icons.update,
          //     ))
        ],
      ),
      body: ReorderableListView(
          physics: const BouncingScrollPhysics(),
          buildDefaultDragHandles: true,
          children: <Widget>[
            for (int index = 0; index < localList.value.length; index++)
              // GridSelectItem(
              //   index,
              //   key: Key('$index'),
              // )
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
                  print('oioioi');
                  // List<DashboardEntry> l = List.from(dash.state);
                  // final newEntry = l.elementAt(index);
                  // l[index] = newEntry.copyWith(enabled: !newEntry.enabled);
                  // dash.state = l;

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
            print('updating localList');
            localList.value = list;
          }),
    );
  }
}

extension DashboardIDX on DashboardID {
  IconData get iconData {
    switch (this) {
      case DashboardID.Versions:
        return KIcons.appVersion;
      case DashboardID.TotalQueries:
        return KIcons.totalQueries;
      case DashboardID.TotalQueries:
        return KIcons.totalQueries;
      case DashboardID.QueriesBlocked:
        return KIcons.queriesBlocked;
      case DashboardID.PercentBlocked:
        return KIcons.percentBlocked;
      case DashboardID.DomainsOnBlocklist:
        return KIcons.domainsOnBlocklist;
      case DashboardID.QueriesBarChart:
        return KIcons.queriesOverTime;
      case DashboardID.ClientActivityBarChart:
        return KIcons.clientActivity;
      case DashboardID.Temperature:
        return KIcons.temperatureReading;
      case DashboardID.Memory:
        return KIcons.memoryUsage;
      case DashboardID.QueryTypes:
        return KIcons.memoryUsage;
      case DashboardID.ForwardDestinations:
        return KIcons.memoryUsage;
      case DashboardID.TopPermittedDomains:
        return KIcons.domainsPermittedTile;
      case DashboardID.TopBlockedDomains:
        return KIcons.domainsBlockedTile;
      case DashboardID.SelectTiles:
        return KIcons.selectDashboardTiles;
      case DashboardID.Logs:
        return KIcons.queryLog; // TODO
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
    return Column(
      children: [
        Divider(height: 0),
        ListTile(
          onTap: onTap,
          title: Text(
            title,
            style: TextStyle(
                color: entry.enabled ? null : Theme.of(context).disabledColor),
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
                child: IconButton(
                  onPressed: null,
                  icon: Icon(Icons.drag_handle),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 0),
      ],
    );
  }
}

class GridSelectItem extends HookWidget {
  const GridSelectItem(this.index, {Key? key}) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    // final dash = useProvider(dashboardProvider);
    final dash = [];
    final entry = dash.elementAt(index);

    final VoidCallback toggle = () {
      // List<DashboardEntry> l = List.from(dash.state);
      // final newEntry = l.elementAt(index);
      // l[index] = newEntry.copyWith(enabled: !newEntry.enabled);
      // dash.state = l;
    };

    return Column(
      children: [
        Divider(height: 0),
        ListTile(
          onTap: toggle,
          title: Text(
            entry.id.toString().split('.').last,
            style: TextStyle(
                color: entry.enabled ? null : Theme.of(context).disabledColor),
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
                  onChanged: (_) => toggle(),
                ),
              ),
              ReorderableDragStartListener(
                index: index,
                child: IconButton(
                  onPressed: null,
                  icon: Icon(Icons.drag_handle),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 0),
      ],
    );
  }
}