import 'package:flutterhole/features/pihole_api/data/models/blacklist.dart';
import 'package:flutterhole/features/pihole_api/data/models/dns_query_type.dart';
import 'package:flutterhole/features/pihole_api/data/models/forward_destinations.dart';
import 'package:flutterhole/features/pihole_api/data/models/list_response.dart';
import 'package:flutterhole/features/pihole_api/data/models/many_query_data.dart';
import 'package:flutterhole/features/pihole_api/data/models/over_time_data.dart';
import 'package:flutterhole/features/pihole_api/data/models/over_time_data_clients.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_client.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_versions.dart';
import 'package:flutterhole/features/pihole_api/data/models/summary.dart';
import 'package:flutterhole/features/pihole_api/data/models/toggle_status.dart';
import 'package:flutterhole/features/pihole_api/data/models/top_items.dart';
import 'package:flutterhole/features/pihole_api/data/models/top_sources.dart';
import 'package:flutterhole/features/pihole_api/data/models/whitelist.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';

/// The string that counts as the API token on Pi-holes
/// without authentication.
///
/// https://github.com/sterrenburg/flutterhole/issues/79
const String kNoApiTokenNeeded = 'No password set';

abstract class ApiDataSource {
  Future<SummaryModel> fetchSummary(PiholeSettings settings);

  Future<ToggleStatus> pingPihole(PiholeSettings settings);

  Future<ToggleStatus> enablePihole(PiholeSettings settings);

  Future<ToggleStatus> disablePihole(PiholeSettings settings);

  Future<ToggleStatus> sleepPihole(PiholeSettings settings, Duration duration);

  Future<OverTimeData> fetchQueriesOverTime(PiholeSettings settings);

  Future<OverTimeDataClients> fetchClientsOverTime(PiholeSettings settings);

  Future<TopSourcesResult> fetchTopSources(PiholeSettings settings);

  Future<TopItems> fetchTopItems(PiholeSettings settings);

  Future<ForwardDestinationsResult> fetchForwardDestinations(
      PiholeSettings settings);

  Future<DnsQueryTypeResult> fetchQueryTypes(PiholeSettings settings);

  Future<PiVersions> fetchVersions(PiholeSettings settings);

  Future<ManyQueryData> fetchQueryDataForClient(
      PiholeSettings settings, PiClient client);

  Future<ManyQueryData> fetchQueryDataForDomain(
      PiholeSettings settings, String domain);

  Future<ManyQueryData> fetchManyQueryData(PiholeSettings settings,
      [int maxResults]);

  Future<Whitelist> fetchWhitelist(PiholeSettings settings);

  Future<Whitelist> fetchRegexWhitelist(PiholeSettings settings);

  Future<ListResponse> addToWhitelist(
      PiholeSettings settings, String domain, bool isWildcard);

  Future<ListResponse> removeFromWhitelist(
      PiholeSettings settings, String domain, bool isWildcard);

  Future<Blacklist> fetchBlacklist(PiholeSettings settings);

  Future<Blacklist> fetchRegexBlacklist(PiholeSettings settings);

  Future<ListResponse> addToBlacklist(
      PiholeSettings settings, String domain, bool isWildcard);

  Future<ListResponse> removeFromBlacklist(
      PiholeSettings settings, String domain, bool isWildcard);
}
