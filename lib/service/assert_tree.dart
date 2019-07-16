// https://github.com/magillus/flutter-fimber/blob/97a0b6d512a4c89c2aaba43cc7eed66c5db8aada/fimber/test/fimber_test.dart#L340

import 'package:fimber/fimber.dart';

class AssertTree extends LogTree {
  List<String> logLevels;
  String lastLogLine;
  List<String> allLines = [];

  AssertTree(this.logLevels);

  @override
  List<String> getLevels() {
    return logLevels;
  }

  @override
  void log(String level, String msg,
      {String tag, dynamic ex, StackTrace stacktrace}) {
    tag = (tag ?? LogTree.getTag());
    lastLogLine =
        "$level:$tag\t$msg\t$ex\n${stacktrace?.toString()?.split('\n') ?? ""}";
    allLines.add(lastLogLine);
  }
}
