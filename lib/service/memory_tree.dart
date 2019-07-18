// https://github.com/magillus/flutter-fimber/blob/97a0b6d512a4c89c2aaba43cc7eed66c5db8aada/fimber/test/fimber_test.dart#L340

import 'package:fimber/fimber.dart';

class LogEntry {
  final String logLine;
  final DateTime timestamp;

  LogEntry(this.logLine) : timestamp = DateTime.now();
}

class MemoryTree extends DebugTree {
  List<LogEntry> logs = [];

  @override
  void printLog(String logLine, {String level}) {
    logs.add(LogEntry(logLine));
    super.printLog(logLine, level: level);
  }
}
