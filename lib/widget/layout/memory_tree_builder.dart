import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterhole/service/converter.dart';
import 'package:flutterhole/service/memory_tree.dart';

const int _maxMessageLength = 500;

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
          return _buildCard(logEntry);
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        },
      ),
    );
  }

  Widget _buildCard(LogEntry logEntry) {
    return ListTile(
      title: Text(_shortLogLine(logEntry)),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(logEntry.level ?? ''),
          Text(
            timestampFormatter.format(logEntry.timestamp),
          ),
        ],
      ),
    );
  }

  String _shortLogLine(LogEntry logEntry) {
    if (logEntry.logLine.length > _maxMessageLength) {
      return '${logEntry.logLine.substring(0, _maxMessageLength)}...';
    }

    return logEntry.logLine;
  }
}
