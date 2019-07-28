import 'package:flutterhole/model/api/top_items.dart';
import "package:test/test.dart";

import '../mock.dart';

void main() {
  TopItems topItems;
  Map<String, dynamic> map;
  String str;
  setUp(() {
    map = {
      "top_queries": mockTopItems.topQueries,
      'top_ads': mockTopItems.topAds
    };
    str =
        '{"top_queries":{"a.com": 1,"b.org": 2,"c.net": 3}, "top_ads":{"ad1.com": 1,"ad2.org": 2,"ad3.net": 3}}';
  });

  test('constructor', () {
    topItems = TopItems(topQueries: {}, topAds: {});
    expect(topItems.topQueries, isEmpty);
    expect(topItems.topAds, isEmpty);
  });

  test('fromString', () {
    expect(TopItems.fromString(str), mockTopItems);
  });

  test('toJson', () {
    expect(mockTopItems.toJson(), map);
  });

  test('fromJson', () {
    expect(TopItems.fromJson(map), mockTopItems);
  });
}
