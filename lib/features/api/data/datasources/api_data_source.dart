import 'package:flutterhole/features/api/data/models/dns_query_type.dart';
import 'package:flutterhole/features/api/data/models/over_time_data.dart';
import 'package:flutterhole/features/api/data/models/summary.dart';
import 'package:flutterhole/features/api/data/models/toggle_status.dart';
import 'package:flutterhole/features/api/data/models/top_sources.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';

class EmptyResponseException implements Exception {}

class NotAuthenticatedException implements Exception {}

class MalformedResponseException implements Exception {}

abstract class ApiDataSource {
  Future<Summary> fetchSummary(PiholeSettings settings);

  Future<ToggleStatus> pingPihole(PiholeSettings settings);

  Future<ToggleStatus> enablePihole(PiholeSettings settings);

  Future<ToggleStatus> disablePihole(PiholeSettings settings);

  Future<ToggleStatus> sleepPihole(PiholeSettings settings, Duration duration);

  Future<OverTimeData> fetchQueriesOverTime(PiholeSettings settings);

  Future<TopSourcesResult> fetchTopSources(PiholeSettings settings);

  Future<DnsQueryTypeResult> fetchQueryTypes(PiholeSettings settings);
}
