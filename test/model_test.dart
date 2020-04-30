import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/features/api/data/models/dns_query_type.dart';
import 'package:flutterhole/features/api/data/models/model.dart';
import 'package:flutterhole/features/api/data/models/over_time_data.dart';
import 'package:flutterhole/features/api/data/models/summary.dart';
import 'package:flutterhole/features/api/data/models/top_items.dart';

import 'fixture_reader.dart';

void testModel<T extends Model>(
    String fixtureName, Function1<Map<String, dynamic>, T> fromJson) {
  test(
    '$T should be cyclical',
    () async {
      // arrange
      final Map<String, dynamic> json = jsonFixture('$fixtureName');
      // act
      final T model = fromJson(json);
      final map = model.toJson();
      // assert
      map.forEach((key, value) {
        expect(json, containsPair(key, value));
      });
    },
  );
}

void main() {
  testModel<Summary>('summaryRaw.json', (json) => Summary.fromJson(json));
  testModel<DnsQueryType>(
      'singleDnsQueryType.json', (json) => DnsQueryType.fromJson(json));
  testModel<DnsQueryTypeResult>(
      'getQueryTypes.json', (json) => DnsQueryTypeResult.fromJson(json));
  testModel<OverTimeData>('overTimeData10mins.json', (json) => OverTimeData.fromJson(json));
  testModel<TopItems>('topItems.json', (json) => TopItems.fromJson(json));
}
