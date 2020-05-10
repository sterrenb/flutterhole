import 'package:flutterhole/features/pihole_api/data/models/dns_query_type.dart';
import 'package:flutterhole/features/pihole_api/data/models/forward_destinations.dart';
import 'package:flutterhole/features/pihole_api/data/models/over_time_data.dart';
import 'package:flutterhole/features/pihole_api/data/models/summary.dart';
import 'package:flutterhole/features/pihole_api/data/models/toggle_status.dart';
import 'package:flutterhole/features/pihole_api/data/models/top_items.dart';
import 'package:flutterhole/features/pihole_api/data/models/top_sources.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';

abstract class ApiDataSource {
  Future<SummaryModel> fetchSummary(PiholeSettings settings);

  Future<ToggleStatus> pingPihole(PiholeSettings settings);

  Future<ToggleStatus> enablePihole(PiholeSettings settings);

  Future<ToggleStatus> disablePihole(PiholeSettings settings);

  Future<ToggleStatus> sleepPihole(PiholeSettings settings, Duration duration);

  Future<OverTimeData> fetchQueriesOverTime(PiholeSettings settings);

  Future<TopSourcesResult> fetchTopSources(PiholeSettings settings);

  Future<TopItems> fetchTopItems(PiholeSettings settings);

  Future<ForwardDestinationsResult> fetchForwardDestinations(
      PiholeSettings settings);

  Future<DnsQueryTypeResult> fetchQueryTypes(PiholeSettings settings);
}
