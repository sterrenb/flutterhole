import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterhole/service/convert.dart';
import 'package:flutterhole/service/memory_tree.dart';

class MemoryTreeBuilder extends StatelessWidget {
  final MemoryTree tree;

  const MemoryTreeBuilder({Key key, @required this.tree}) : super(key: key);

  void copyToClipboard() {
    Clipboard.setData(new ClipboardData(
        text: tree.logs
            .map((logEntry) => '${logEntry.timestamp}: ${logEntry.logLine}')
            .toString()));
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ListView.separated(
        itemCount: tree.logs.length,
        itemBuilder: (BuildContext context, int index) {
          final LogEntry logEntry = tree.logs[index];
          return ListTile(
            title: Text(logEntry.logLine),
            subtitle: Text(
              timestampFormatter.format(logEntry.timestamp),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        },
      ),
    );
  }
}
