import 'dart:async';

import 'package:fimber/fimber.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/service/memory_tree.dart';

var mockLog;

overridePrint(testFn()) => () {
      var spec = new ZoneSpecification(print: (_, __, ___, String msg) {
        // Add to log instead of printing to stdout
        mockLog.add(msg);
      });
      return Zone.current.fork(specification: spec).run(testFn);
    };

void main() {
  MemoryTree memoryTree;
  LogEntry logEntry;

  setUp(() {
    logEntry = LogEntry('test');
    mockLog = [];
    memoryTree = MemoryTree();
    Fimber.plantTree(memoryTree);
  });

  test('override print', overridePrint(() {
    print('hello world');
    expect(mockLog, ['hello world']);
  }));

  test('LogEntry', () {
    expect(logEntry.logLine, 'test');
  });

  test('printLog', overridePrint(() {
    memoryTree.printLog('printLog');
    expect(memoryTree.logs.first.logLine, 'printLog');
    expect(mockLog.toString().contains('printLog'), isTrue);
  }));
}
