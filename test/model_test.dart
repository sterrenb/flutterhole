import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/features/api/data/models/blacklist.dart';
import 'package:flutterhole/features/api/data/models/dns_query_type.dart';
import 'package:flutterhole/features/api/data/models/model.dart';
import 'package:flutterhole/features/api/data/models/over_time_data.dart';
import 'package:flutterhole/features/api/data/models/pi_client.dart';
import 'package:flutterhole/features/api/data/models/summary.dart';
import 'package:flutterhole/features/api/data/models/top_items.dart';
import 'package:flutterhole/features/api/data/models/top_sources.dart';
import 'package:flutterhole/features/api/data/models/whitelist.dart';

import 'fixture_reader.dart';

void testMapModel<T extends MapModel>(
    String fixtureName, Function1<Map<String, dynamic>, T> fromJson) {
  test(
    '$T toJson/fromJson should be cyclical',
    () async {
      // arrange
      final Map<String, dynamic> json = jsonFixture('$fixtureName');
      // act
      final T model = fromJson(json);
      final Map<String, dynamic> map = model.toJson();
      // assert
      expect(map, equals(json));
    },
  );
}

void testListModel<T extends ListModel>(
    String fixtureName, Function1<List<dynamic>, T> fromList) {
  test(
    '$T toJson/fromJson should be cyclical',
    () async {
      // arrange
      final List<dynamic> json = jsonFixture('$fixtureName');
      // act
      final T model = fromList(json);
      final List<dynamic> list = model.toList();
      // assert
      expect(list, equals(json));
    },
  );
}

void main() {
  testMapModel<Summary>('summaryRaw.json', (json) => Summary.fromJson(json));
  testMapModel<DnsQueryType>(
      'singleDnsQueryType.json', (json) => DnsQueryType.fromJson(json));
  testMapModel<DnsQueryTypeResult>(
      'getQueryTypes.json', (json) => DnsQueryTypeResult.fromJson(json));
  testMapModel<OverTimeData>(
      'overTimeData10mins.json', (json) => OverTimeData.fromJson(json));
  testMapModel<TopItems>('topItems.json', (json) => TopItems.fromJson(json));
  testMapModel<PiClient>(
      'singlePiClient.json', (json) => PiClient.fromJson(json));
  testMapModel<TopSourcesResult>(
      'getQuerySources.json', (json) => TopSourcesResult.fromJson(json));
  testListModel<Blacklist>(
      'blacklist.json', (json) => Blacklist.fromList(json));
  testListModel<Whitelist>(
      'whitelist.json', (json) => Whitelist.fromList(json));
}
