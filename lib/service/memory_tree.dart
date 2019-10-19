// https://github.com/magillus/flutter-fimber/blob/97a0b6d512a4c89c2aaba43cc7eed66c5db8aada/fimber/test/fimber_test.dart#L340

import 'package:fimber/fimber.dart';

class LogEntry {
  LogEntry(this.logLine, {this.level}) : timestamp = DateTime.now();

  final String logLine;
  final String level;
  final DateTime timestamp;
}

class MemoryTree extends DebugTree {
  List<LogEntry> logs = [];

  @override
  void printLog(String logLine, {String level}) {
    logs.insert(0, LogEntry(logLine, level: level));
    super.printLog(logLine, level: level);
  }
}
