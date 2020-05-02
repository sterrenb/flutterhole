import 'package:flutterhole/features/api/data/models/dns_query_type.dart';
import 'package:flutterhole/features/api/data/models/over_time_data.dart';
import 'package:flutterhole/features/api/data/models/summary.dart';
import 'package:flutterhole/features/api/data/models/toggle_status.dart';
import 'package:flutterhole/features/api/data/models/top_sources.dart';

class EmptyResponseException implements Exception {}

class NotAuthenticatedException implements Exception {}

class MalformedResponseException implements Exception {}

abstract class ApiDataSource {
  Future<Summary> fetchSummary();

  Future<ToggleStatus> pingPihole();

  Future<ToggleStatus> enablePihole(String apiToken);

  Future<ToggleStatus> disablePihole(String apiToken);

  Future<ToggleStatus> sleepPihole(String apiToken, Duration duration);

  Future<OverTimeData> fetchQueriesOverTime();

  Future<TopSourcesResult> fetchTopSources(String apiToken);

  Future<DnsQueryTypeResult> fetchQueryTypes(String apiToken);
}
