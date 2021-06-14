import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/grid/grid_layout.dart';
import 'package:flutterhole_web/features/layout/code_card.dart';
import 'package:flutterhole_web/features/layout/periodic_widget.dart';
import 'package:flutterhole_web/features/layout/transparent_app_bar.dart';
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
                  Hero(
                    tag: record.message,
                    child: CodeCard(
                      record.message,
                      onTap: () {
                        // Navigator.of(context)
                        //     .push(MaterialPageRoute<void>(builder: (context) {
                        //   return LogRecordPage(record);
                        // }));

                        showModal(
                          context: context,
                          builder: (context) {
                            return LogRecordModal(record);
                          },
                        );
                      },
                    ),
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

class LogRecordModal extends StatelessWidget {
  const LogRecordModal(this.record, {Key? key}) : super(key: key);

  final LogRecord record;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: MediaQuery.of(context).size.width / 2,
          // height: MediaQuery.of(context).size.height / 3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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

class LogRecordPage extends HookWidget {
  const LogRecordPage(this.record, {Key? key}) : super(key: key);

  final LogRecord record;

  @override
  Widget build(BuildContext context) {
    final controller = useScrollController();
    return Scaffold(
      appBar: TransparentAppBar(
        controller: controller,
        title: Text('Hi there'),
      ),
      body: Container(
        color: Colors.green,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: record.message,
              child: CodeCard(
                record.message,
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
