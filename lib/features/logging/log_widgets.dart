import 'dart:math';
import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/entities/settings_entities.dart';
import 'package:flutterhole_web/features/layout/code_card.dart';
import 'package:flutterhole_web/features/layout/list.dart';
import 'package:flutterhole_web/features/layout/media_queries.dart';
import 'package:flutterhole_web/features/layout/periodic_widget.dart';
import 'package:flutterhole_web/features/logging/loggers.dart';
import 'package:flutterhole_web/features/themes/theme_builders.dart';
import 'package:flutterhole_web/formatting.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:timeago/timeago.dart' as timeago;

extension LogRecordX on LogRecord {
  IconData get iconData {
    switch (this.level.name) {
      case 'INFO':
      case 'ALL':
        return KIcons.info;
      case 'FINEST':
      case 'FINER':
      case 'FINE':
      case 'CONFIG':
      case 'WARNING':
        return KIcons.logDebug;
      case 'SEVERE':
      case 'SHOUT':
        return KIcons.logDebug;
      case 'OFF':
      default:
        return KIcons.unknown;
    }
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

  String get readable {
    switch (this.name) {
      case 'ALL':
      case 'FINEST':
      case 'FINER':
      case 'FINE':
      case 'CONFIG':
        return 'Debug';
      case 'INFO':
        return 'Info';
      case 'WARNING':
        return 'Warning';
      case 'SEVERE':
      case 'SHOUT':
      case 'OFF':
      default:
        return 'Error';
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

class _LogRecordModal extends StatelessWidget {
  const _LogRecordModal(this.record, {Key? key}) : super(key: key);

  final LogRecord record;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: context.dialogPadding,
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: _RecordIconBuilder(record: record),
                title: Text('${record.level.readable}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${record.time.hms}',
                      style: Theme.of(context).textTheme.caption,
                    ),
                    DifferenceText(record.time),
                  ],
                ),
                // subtitle: Text('name: ${record.loggerName}'),
              ),
              SelectableCodeCard(
                record.message,
                // onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecordTile extends StatelessWidget {
  const RecordTile({
    Key? key,
    required this.record,
    required this.singleLine,
  }) : super(key: key);

  final LogRecord record;
  final bool singleLine;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _RecordIconBuilder(record: record),
      title: CodeCard(
        code: record.message,
        singleLine: singleLine,
      ),
      trailing: Column(
        // mainAxisSize: MainAxisSize.max,
        mainAxisAlignment:
            singleLine ? MainAxisAlignment.center : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            record.time.hms,
            style: Theme.of(context).textTheme.caption,
          ),
          DifferenceText(record.time),
        ],
      ),
      // onTap: onTap,
      onTap: () {
        showModal(
          context: context,
          builder: (context) {
            return _LogRecordModal(record);
          },
        );
      },
    );
  }
}

class AnimatedRecordTile extends HookWidget {
  const AnimatedRecordTile(
    this.index,
    this.record,
    this.onTap,
    this.animation,
    this.singleLine, {
    Key? key,
  }) : super(key: key);

  final int index;
  final LogRecord record;
  final VoidCallback? onTap;
  final Animation<double> animation;
  final bool singleLine;

  @override
  Widget build(BuildContext context) {
    return AnimatedListTile(
        animation: animation,
        child: RecordTile(record: record, singleLine: singleLine));
  }
}

class _RecordIconBuilder extends StatelessWidget {
  const _RecordIconBuilder({
    Key? key,
    required this.record,
  }) : super(key: key);

  final LogRecord record;

  @override
  Widget build(BuildContext context) {
    return PiColorsBuilder(
      builder: (context, piColors, _) => Icon(
        record.level.iconData,
        color: record.level.getColor(piColors),
      ),
    );
  }
}

class DifferenceText extends HookWidget {
  const DifferenceText(this.dateTime, {Key? key, this.textStyle})
      : super(key: key);

  final DateTime dateTime;
  final TextStyle? textStyle;

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
        style: textStyle ?? Theme.of(context).textTheme.caption,
      ),
    );
  }
}

class LogsListView extends HookWidget {
  const LogsListView({
    Key? key,
    this.controller,
    this.maxLength,
    required this.shrinkWrap,
    required this.singleLine,
  }) : super(key: key);

  final ScrollController? controller;
  final int? maxLength;
  final bool singleLine;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final List<LogRecord> records = useProvider(logNotifierProvider);

    return ListView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: const NeverScrollableScrollPhysics(),
      itemCount:
          maxLength != null ? min(records.length, maxLength!) : records.length,
      itemBuilder: (context, index) => RecordTile(
        record: records.elementAt(index),
        singleLine: singleLine,
      ),
    );
  }
}

class AnimatedLogsList extends HookWidget {
  const AnimatedLogsList({
    Key? key,
    this.controller,
    required this.maxLength,
    required this.shrinkWrap,
    required this.singleLine,
  }) : super(key: key);

  final ScrollController? controller;
  final int maxLength;
  final bool singleLine;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final List<LogRecord> records = useProvider(logNotifierProvider);
    final list = useState(records.sublist(0, min(maxLength, records.length)));
    final k = useState(GlobalKey<AnimatedListState>()).value;

    void deleteAtIndex(LogRecord record, int index) {
      list.value = [...list.value..removeAt(index)];
      k.currentState?.removeItem(
          index,
          (context, animation) =>
              AnimatedRecordTile(index, record, null, animation, singleLine));
    }

    void deleteLast() {
      final record = list.value.last;
      list.value = [...list.value..removeAt(list.value.length - 1)];
      k.currentState?.removeItem(
          list.value.length,
          (context, animation) =>
              AnimatedRecordTile(0, record, null, animation, singleLine));
    }

    useEffect(() {
      if (records.isEmpty ||
          (list.value.isNotEmpty && list.value.first == records.last)) {
        return;
      }

      list.value = [
        records.first,
        ...list.value,
      ];

      k.currentState?.insertItem(0);

      if (list.value.length > maxLength) {
        deleteLast();
      }
    }, [records]);

    return AnimatedList(
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: const NeverScrollableScrollPhysics(),
      key: k,
      initialItemCount: list.value.length,
      itemBuilder: (context, index, animation) {
        final record = list.value.elementAt(index);
        return AnimatedRecordTile(index, record, () {
          deleteAtIndex(record, index);
        }, animation, singleLine);
      },
    );
  }
}
