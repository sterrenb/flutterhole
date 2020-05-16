import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/features/pihole_api/data/models/blacklist.dart';
import 'package:flutterhole/features/pihole_api/data/models/dns_query_type.dart';
import 'package:flutterhole/features/pihole_api/data/models/forward_destinations.dart';
import 'package:flutterhole/features/pihole_api/data/models/many_query_data.dart';
import 'package:flutterhole/features/pihole_api/data/models/model.dart';
import 'package:flutterhole/features/pihole_api/data/models/over_time_data.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_client.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_versions.dart';
import 'package:flutterhole/features/pihole_api/data/models/query_data.dart';
import 'package:flutterhole/features/pihole_api/data/models/summary.dart';
import 'package:flutterhole/features/pihole_api/data/models/toggle_status.dart';
import 'package:flutterhole/features/pihole_api/data/models/top_items.dart';
import 'package:flutterhole/features/pihole_api/data/models/top_sources.dart';
import 'package:flutterhole/features/pihole_api/data/models/whitelist.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';

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
  testMapModel<SummaryModel>(
      'summary_raw.json', (json) => SummaryModel.fromJson(json));
  testMapModel<DnsQueryType>(
      'single_dns_query_type.json', (json) => DnsQueryType.fromJson(json));
  testMapModel<DnsQueryTypeResult>(
      'get_query_types.json', (json) => DnsQueryTypeResult.fromJson(json));
  testMapModel<OverTimeData>(
      'over_time_data_10mins.json', (json) => OverTimeData.fromJson(json));
  testMapModel<TopItems>('top_items.json', (json) => TopItems.fromJson(json));
  testMapModel<PiClient>(
      'single_pi_client.json', (json) => PiClient.fromJson(json));
  testMapModel<TopSourcesResult>(
      'get_query_sources.json', (json) => TopSourcesResult.fromJson(json));
  testMapModel<ForwardDestination>('single_forward_destination.json',
          (json) => ForwardDestination.fromJson(json));
  testMapModel<ForwardDestinationsResult>('get_forward_destinations.json',
          (json) => ForwardDestinationsResult.fromJson(json));
  testListModel<Blacklist>(
      'blacklist.json', (json) => Blacklist.fromList(json));
  testListModel<Whitelist>(
      'whitelist.json', (json) => Whitelist.fromList(json));
  testListModel<QueryData>(
      'query_data_single.json', (json) => QueryData.fromList(json));
  testMapModel<ManyQueryData>(
      'get_all_queries_2.json', (json) => ManyQueryData.fromJson(json));
  testMapModel<ToggleStatus>(
      'status_enabled.json', (json) => ToggleStatus.fromJson(json));
  testMapModel<ToggleStatus>(
      'status_disabled.json', (json) => ToggleStatus.fromJson(json));
  testMapModel<PiVersions>(
      'get_versions.json', (json) => PiVersions.fromJson(json));

  testMapModel<PiholeSettings>(
      'pihole_settings_default.json', (json) => PiholeSettings.fromJson(json));
}
