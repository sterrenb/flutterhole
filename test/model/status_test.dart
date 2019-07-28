import 'package:flutterhole/model/api/status.dart';
import "package:test/test.dart";

import '../mock.dart';

void main() {
  Status status;
  Map<String, dynamic> map;
  String str;
  setUp(() {
    map = {"status": "enabled"};
    print(map.toString());
    str = '{"status": "enabled"}';
  });

  test('constructor', () {
    status = Status(enabled: true);
    expect(status.enabled, isTrue);
    expect(status.disabled, isFalse);
  });

  test('fromString', () {
    expect(Status.fromString(str), mockStatusEnabled);
  });

  test('toJson', () {
    expect(mockStatusEnabled.toJson(), map);
  });

  test('fromJson', () {
    expect(Status.fromJson(map), mockStatusEnabled);
  });
}
