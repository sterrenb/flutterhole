import 'package:flutterhole/model/api/whitelist.dart';
import "package:test/test.dart";

import '../mock.dart';

void main() {
  Whitelist whitelist;
  List<dynamic> list;
  String str;
  setUp(() {
    list = [
      [
        'a.com',
        'b.org',
        'c.net',
      ]
    ];
    str = '[[\"a.com\",\"b.org\",\"c.net\"]]';
  });

  test('constructor', () {
    whitelist = Whitelist();
    expect(whitelist.list, isEmpty);
  });

  test('fromString', () {
    expect(Whitelist.fromString(str), mockWhitelist);
  });

  test('toJson', () {
    expect(mockWhitelist.toJson(), str);
  });

  test('fromJson', () {
    expect(Whitelist.fromJson(list), mockWhitelist);
  });

  test('withItem', () {
    final newList = Whitelist.withItem(mockWhitelist, 'new');
    expect(newList.list, mockWhitelist.list..add('new'));
  });

  test('withoutItem', () {
    final newList =
        Whitelist.withoutItem(mockWhitelist, mockWhitelist.list.last);
    expect(newList.list, mockWhitelist.list..removeLast());
  });
}
