import 'package:flutterhole/model/api/top_sources.dart';
import "package:test/test.dart";

import '../mock.dart';

void main() {
  TopSources topSources;
  Map<String, dynamic> map;
  String str;
  setUp(() {
    map = {
      "top_sources": {
        '10.0.1.1': 55,
        '10.0.1.2': 42,
        'windows|10.0.1.3': 33,
        'osx|10.0.1.4': 24,
      }
    };
    str =
        '{\"top_sources\":{\"10.0.1.1\":55,\"10.0.1.2\":42,\"windows|10.0.1.3\":33,\"osx|10.0.1.4\":24}}';
  });

  test('constructor', () {
    topSources = TopSources({});
    expect(topSources.values, isEmpty);
    expect(topSources.items, isEmpty);
  });

  test('items', () {
    expect(mockTopSources.items, [
      TopSourceItem(ipString: '10.0.1.1', requests: 55),
      TopSourceItem(ipString: '10.0.1.2', requests: 42),
      TopSourceItem(ipString: '10.0.1.3', title: 'windows', requests: 33),
      TopSourceItem(ipString: '10.0.1.4', title: 'osx', requests: 24),
    ]);
  });

  test('fromString', () {
    expect(TopSources.fromString(str), mockTopSources);
  });

  test('toJson', () {
    expect(mockTopSources.toJson(), map);
  });

  test('fromJson', () {
    expect(TopSources.fromJson(map), mockTopSources);
  });
}
