import 'package:flutterhole/model/api/blacklist.dart';
import "package:test/test.dart";

import '../mock.dart';

void main() {
  Blacklist blacklist;
  List<dynamic> list;
  Map<String, dynamic> map;
  String str;
  setUp(() {
    map = {
      'exact': mockBlacklist.exact,
      'wildcard': mockBlacklist.wildcard,
    };
    list = [
      [
        'exact.com',
        'pi-hole.net',
      ],
      [
        '${wildcardPrefix}wildcard.com$wildcardSuffix',
        'regex',
      ]
    ];
    str =
        '{"exact":[{"entry":"exact.com","type":"exact"},{"entry":"pi-hole.net","type":"exact"}],"wildcard":[{"entry":"'
        r'(^|\\.)'
        'wildcard.com\$","type":"wildcard"},{"entry":"regex","type":"regex"}]}';
  });

  test('constructor', () {
    blacklist = Blacklist();
    expect(blacklist.exact, isEmpty);
    expect(blacklist.wildcard, isEmpty);
  });

  test('fromString', () {
    expect(Blacklist.fromString(str), mockBlacklist);
  });

  test('toJson', () {
    expect(mockBlacklist.toJson(), map);
  });

  test('fromJson', () {
    expect(Blacklist.fromJson(list), mockBlacklist);
  });

  test('withItem', () {
    final exactItem = BlacklistItem.exact(entry: 'new');
    final exactList = Blacklist.withItem(mockBlacklist, exactItem);
    expect(exactList.exact, mockBlacklist.exact..add(exactItem));

    final wildcardItem = BlacklistItem.wildcard(entry: 'new');
    final wildcardList = Blacklist.withItem(mockBlacklist, wildcardItem);
    expect(wildcardList.wildcard, mockBlacklist.wildcard..add(wildcardItem));
  });

  test('withoutItem', () {
    final exactItem = mockBlacklist.exact.last;
    final exactList = Blacklist.withoutItem(mockBlacklist, exactItem);
    expect(exactList.exact, mockBlacklist.exact..remove(exactItem));

    final wildcardItem = mockBlacklist.wildcard.last;
    final wildcardList = Blacklist.withoutItem(mockBlacklist, wildcardItem);
    expect(wildcardList.wildcard, mockBlacklist.wildcard..remove(wildcardItem));
  });

  group('blacklistTypeFromString', () {
    test('exact', () {
      expect(blacklistTypeFromString('exact'), BlacklistType.Exact);
    });

    test('invalid', () {
      try {
        blacklistTypeFromString('invalid');
        fail('exception not thrown');
      } catch (e) {
        expect(e, TypeMatcher<FormatException>());
      }
    });
  });

  group('BlacklistItem', () {
    BlacklistItem itemRegex;

    setUp(() {
      itemRegex = BlacklistItem.regex(entry: 'regex');
    });

    test('toJson', () {
      expect(mockBlacklist.exact.first.toJson(),
          {'entry': 'exact.com', 'type': 'exact'});
    });

    test('list', () {
      expect(itemRegex.addList, 'regex');
    });

    test('listKey', () {
      expect(BlacklistItem.exact(entry: '').listKey, 'exact');
      expect(BlacklistItem.wildcard(entry: '').listKey, 'wildcard');
      expect(BlacklistItem.regex(entry: '').listKey, 'regex');

      try {
        final invalidItem = BlacklistItem(entry: 'invalid', type: null);
        invalidItem.listKey;
        fail('exception not thrown');
      } catch (e) {
        expect(e, TypeMatcher<Exception>());
      }
    });
  });
}
