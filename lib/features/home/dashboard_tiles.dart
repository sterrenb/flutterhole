import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/entities/settings_entities.dart';
import 'package:flutterhole_web/features/grid/grid_layout.dart';
import 'package:flutterhole_web/features/layout/code_card.dart';
import 'package:flutterhole_web/features/layout/periodic_widget.dart';
import 'package:flutterhole_web/features/logging/log_widgets.dart';
import 'package:flutterhole_web/features/logging/loggers.dart';
import 'package:flutterhole_web/features/pihole/active_pi.dart';
import 'package:flutterhole_web/features/themes/theme_builders.dart';
import 'package:flutterhole_web/formatting.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:timeago/timeago.dart' as timeago;

const double kMinTileHeight = 150.0;

class TextTileBottomText extends StatelessWidget {
  const TextTileBottomText(
    this.title, {
    Key? key,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

class TextTileContent extends StatelessWidget {
  final Widget top;
  final Widget bottom;
  final IconData iconData;
  final double iconLeft;
  final double? iconTop;

  const TextTileContent({
    Key? key,
    required this.top,
    required this.bottom,
    required this.iconData,
    this.iconLeft = 16.0,
    this.iconTop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Positioned(
          left: iconLeft,
          top: iconTop,
          child: GridIcon(iconData),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: top,
            ),
            Center(
              child: bottom,
            ),
          ],
        ),
      ],
    );
  }
}

class DashboardListIcon extends StatelessWidget {
  const DashboardListIcon(
    this.primaryIcon, {
    Key? key,
  }) : super(key: key);

  final IconData primaryIcon;

  @override
  Widget build(BuildContext context) {
    return Icon(
      primaryIcon,
      size: 32.0,
      color: Colors.white.withOpacity(0.5),
    );
  }
}

class _QueryItemDivider extends StatelessWidget {
  const _QueryItemDivider({
    Key? key,
    this.color,
  }) : super(key: key);

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 0,
      indent: 16.0,
      endIndent: 16.0,
      color: color,
    );
  }
}

class _QueryItemTile extends StatelessWidget {
  const _QueryItemTile(
    this.entry, {
    Key? key,
  }) : super(key: key);

  final MapEntry<String, int> entry;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        entry.key,
        // maxLines: 1,
      ),
      trailing: Text(entry.value.toString()),
      onTap: () {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          content: Text(
            '${entry.key}: ${entry.value} requests',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          duration: Duration(seconds: 1),
        ));
      },
    );
  }
}

class TopPermittedDomainsTile extends HookWidget {
  const TopPermittedDomainsTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topItems = useProvider(activeTopItemsProvider);
    final expanded = useState(false);
    final ticker = useSingleTickerProvider();
    return Card(
      child: AnimatedSize(
        vsync: ticker,
        duration: kThemeAnimationDuration * 2,
        alignment: Alignment.topCenter,
        curve: Curves.ease,
        child: Column(
          children: [
            ListTile(
              // tileColor: Colors.green.withOpacity(0.1),
              title: TileTitle(
                'Permitted Domains',
              ),
              leading: GridIcon(
                KIcons.domainsPermittedTile,
                subIcon: Icons.check_box,
                subIconColor: Colors.green,
              ),
              onTap: topItems.maybeWhen(
                data: (_) => () {
                  expanded.value = !expanded.value;
                },
                orElse: () => null,
              ),
              trailing: Icon(expanded.value ? KIcons.shrink : KIcons.expand),
            ),
            topItems.when(
              data: (topItems) {
                return ListView.separated(
                  itemCount: expanded.value ? topItems.topQueries.length : 3,
                  shrinkWrap: true,
                  primary: false,
                  separatorBuilder: (context, index) => const _QueryItemDivider(
                    color: Colors.green,
                  ),
                  itemBuilder: (context, index) {
                    final entry = topItems.topQueries.entries.elementAt(index);
                    return _QueryItemTile(entry);
                  },
                );
              },
              loading: () => Container(
                  height: kMinTileHeight,
                  child: Center(child: CircularProgressIndicator())),
              error: (error, stacktrace) => Column(
                children: [
                  ListTile(
                    title: ExpandableCode(
                      error.toString(),
                      tappable: false,
                    ),
                  ),
                  ExpandableCode(
                    stacktrace.toString(),
                    // tappable: false,
                  ),
                ],
              ),
            ),
            Container(
              height: 5.0,
            ),
          ],
        ),
      ),
    );
  }
}

class TopBlockedDomainsTile extends HookWidget {
  const TopBlockedDomainsTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topItems = useProvider(activeTopItemsProvider);
    final expanded = useState(false);
    final ticker = useSingleTickerProvider();
    // return Card(
    //   child: Center(child: Text('hi')),
    // );

    return Card(
      child: AnimatedSize(
        vsync: ticker,
        duration: kThemeAnimationDuration * 2,
        alignment: Alignment.topCenter,
        curve: Curves.ease,
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            Container(
              // color: Colors.orange,
              height: 80,
              child: ListTile(
                // tileColor: Colors.red.withOpacity(0.1),
                title: TileTitle(
                  'Blocked Domains',
                ),
                leading: GridIcon(
                  KIcons.domainsPermittedTile,
                  subIcon: Icons.remove_circle,
                  subIconColor: Colors.red,
                ),
                onTap: topItems.maybeWhen(
                  data: (_) => () {
                    expanded.value = !expanded.value;
                  },
                  orElse: () => null,
                ),
                trailing: Icon(expanded.value ? KIcons.shrink : KIcons.expand),
              ),
            ),
            topItems.when(
              data: (topItems) {
                return ListView.separated(
                  itemCount: expanded.value ? topItems.topAds.length : 3,
                  shrinkWrap: true,
                  primary: false,
                  separatorBuilder: (context, index) =>
                      const _QueryItemDivider(color: Colors.red),
                  itemBuilder: (context, index) {
                    final entry = topItems.topAds.entries.elementAt(index);
                    return _QueryItemTile(entry);
                  },
                );
              },
              loading: () => Container(
                  height: kToolbarHeight * 5,
                  child: Center(child: CircularProgressIndicator())),
              error: (error, stacktrace) =>
                  ExpandableCode(stacktrace.toString()),
            ),
            Container(
              height: 5.0,
            ),
          ],
        ),
      ),
    );
  }
}

// var index = 0;

class LogsTile extends HookWidget {
  const LogsTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logs = useProvider(logStreamProvider);
    final list = useProvider(logNotifierProvider);
    final height = useState(kMinTileHeight);
    return GridCard(
      child: GridInkWell(
        // onTap: () {
        //   if (height.value == kMinTileHeight) {
        //     height.value = kMinTileHeight * 4;
        //   } else {
        //     height.value = kMinTileHeight;
        //   }
        //   // context.read(logNotifierProvider.notifier).log(LogCall(
        //   //     source: 'dashboard',
        //   //     level: LogLevel.warning,
        //   //     message: "Hello my fren: ${index++}"));
        // },
        child: 5 < 6
            ? LogsLiveList()
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final record = list.elementAt(index);
                  return LogRecordRow(record: record);
                },
              ),
      ),
    );
  }
}

class DifferenceText extends HookWidget {
  const DifferenceText(this.dateTime, {Key? key}) : super(key: key);

  final DateTime dateTime;

  @override
  Widget build(BuildContext context) {
    final now = useState(DateTime.now());
    final duration = now.value.difference(dateTime);
    final dif = now.value.subtract(duration);
    //
    // useEffect(() {
    //   return Timer.periodic(Duration(seconds: 2), (timer) {
    //     print('tick ${timer.tick}');
    //     now.value = now.value.add(Duration(seconds: 2));
    //   }).cancel;
    // }, const []);

    return PeriodicWidget(
      duration: kRefreshDuration,
      onTimer: (timer) {
        now.value = now.value.add(kRefreshDuration);
      },
      child: Text(
        timeago.format(dif),
        style: Theme.of(context).textTheme.caption,
      ),
    );
  }
}

extension LevelX on Level {
  IconData get iconData {
    switch (this.name) {
      case 'ALL':
      case 'FINEST':
      case 'FINER':
      case 'FINE':
      case 'CONFIG':
        return KIcons.debugLogs;
      case 'INFO':
        return KIcons.info;
      case 'WARNING':
        return KIcons.logWarning;
      case 'SEVERE':
      case 'SHOUT':
      case 'OFF':
      default:
        return KIcons.logError;
    }
  }

  Color getColor(PiColorTheme piColors) {
    switch (this.name) {
      case 'ALL':
      case 'FINEST':
      case 'FINER':
      case 'FINE':
      case 'CONFIG':
        return piColors.debug;
      case 'INFO':
        return piColors.info;
      case 'WARNING':
        return piColors.warning;
      case 'SEVERE':
      case 'SHOUT':
      case 'OFF':
      default:
        return piColors.error;
    }
  }
}

class _LogRecordTile extends StatelessWidget {
  const _LogRecordTile(
    this.index,
    this.record,
    this.onTap,
    this.animation, {
    Key? key,
  }) : super(key: key);

  final int index;
  final LogRecord record;
  final VoidCallback? onTap;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      axis: Axis.vertical,
      sizeFactor: animation,
      // axisAlignment: 1.0,
      child: FadeTransition(
        opacity: animation,
        child: ListTile(
          leading: PiColorsBuilder(
            builder: (context, piColors, _) => Icon(
              record.level.iconData,
              color: record.level.getColor(piColors),
            ),
          ),
          title: CodeCard(record.message),
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.time.hms,
                style: Theme.of(context).textTheme.caption,
              ),
              DifferenceText(record.time),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

class LogsLiveList extends HookWidget {
  const LogsLiveList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<LogRecord> records = useProvider(logNotifierProvider);
    final list = useState(records);
    final k = useState(GlobalKey<AnimatedListState>()).value;

    void deleteLast() {
      final record = list.value.last;
      list.value = [...list.value..removeAt(list.value.length - 1)];
      k.currentState?.removeItem(list.value.length,
          (context, animation) => _LogRecordTile(0, record, null, animation));
    }

    void deleteAtIndex(LogRecord record, int index) {
      list.value = [...list.value..removeAt(index)];
      k.currentState?.removeItem(
          index,
          (context, animation) =>
              _LogRecordTile(index, record, null, animation));
    }

    void clearAll() async {
      final reversed = list.value;
      for (int index = reversed.length - 1; index >= 0; index--) {
        final x = 0;
        final record = reversed.elementAt(x);
        deleteAtIndex(record, x);
        await Future.delayed(Duration(milliseconds: 100));
      }
    }

    Widget buildClearButton() => Visibility(
          visible: true,
          child: TextButton(
            onPressed: list.value.isEmpty
                ? null
                : () {
                    // deleteFirst();
                    // deleteLast();
                    clearAll();
                  },
            child: Text('Clear'),
          ),
        );

    useEffect(() {
      if (records.isNotEmpty && records.last != list.value.first) {
        list.value = [
          records.last,
          ...list.value,
        ];
        // q.value.add(records.last);

        k.currentState?.insertItem(0);

        if (list.value.length > kLogCacheLength) {
          deleteLast();
        }
      }
    }, [records]);

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 0.0,
        // maxHeight: kToolbarHeight * (kLogCacheLength + 3),
      ),
      child: Scrollbar(
        child: ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            ListTile(
              title: TileTitle('Logs'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  buildClearButton(),
                  Visibility(
                    visible: false,
                    child: TextButton(
                      child: Text('Add'),
                      onPressed: () {
                        context.log(LogCall(
                            source: 'add',
                            level: LogLevel.warning,
                            message: 'yooo ${records.length}'));
                        // list.value = [
                        //   LogRecord(
                        //     Level.FINE,
                        //     'Testing ${list.value.length}',
                        //     'mememe',
                        //   ),
                        //   ...list.value
                        // ];
                        // k.currentState?.insertItem(0);
                        //
                        // if (list.value.length > kLogCacheLength) {
                        //   deleteLast();
                        // }
                      },
                    ),
                  ),
                ],
              ),
            ),
            AnimatedList(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              key: k,
              initialItemCount: list.value.length,
              itemBuilder: (context, index, animation) {
                final record = list.value.elementAt(index);
                return _LogRecordTile(index, record, () {
                  deleteAtIndex(record, index);
                }, animation);
              },
            ),
            ListTile(
              // subtitle: Text('${list.value.length}/${records.length}'),
              // leading: buildClearButton(),
              trailing: TextButton(
                child: Text(
                    'View ${numberFormat.format(records.length * 59)} logs'),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
