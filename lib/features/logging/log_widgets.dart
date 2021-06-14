import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/grid/grid_layout.dart';
import 'package:flutterhole_web/features/layout/code_card.dart';
import 'package:flutterhole_web/features/layout/periodic_widget.dart';
import 'package:flutterhole_web/formatting.dart';
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
        return KIcons.logDebug;
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

class LogRecordRow extends HookWidget {
  const LogRecordRow({
    Key? key,
    required this.record,
  }) : super(key: key);

  final LogRecord record;

  static const refreshDuration = Duration(seconds: 1);

  @override
  Widget build(BuildContext context) {
    final now = useState(DateTime.now());
    final toggled = useState(false);
    final duration = now.value.difference(record.time);
    final dif = now.value.subtract(duration);
    return Card(
      key: ValueKey(record),
      elevation: 0.0,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Flexible(
              flex: 3,
              child: Tooltip(
                message: record.time.jms,
                child: Card(
                  elevation: 0.0,
                  color: Colors.transparent,
                  child: GridInkWell(
                    onTap: () {
                      toggled.value = !toggled.value;
                    },
                    child: Row(
                      children: [
                        Icon(
                          record.iconData,
                          // size: 12.0,
                        ),
                        SizedBox(width: 8.0),
                        PeriodicWidget(
                          duration: refreshDuration,
                          onTimer: (_) {
                            now.value = now.value.add(refreshDuration);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(record.time.hms),
                              AnimatedSwitcher(
                                duration: kThemeAnimationDuration,
                                child: toggled.value
                                    ? Text('+${duration.inSeconds}S',
                                        key: const ValueKey('seconds'),
                                        style:
                                            Theme.of(context).textTheme.caption)
                                    : Text(
                                        timeago.format(dif),
                                        key: const ValueKey('timeago'),
                                        style:
                                            Theme.of(context).textTheme.caption,
                                        // overflow: TextOverflow.ellipsis,
                                        // softWrap: true,
                                        // maxLines: 2,
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Icon(KIcons.info),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CodeCard(
                    record.message,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
