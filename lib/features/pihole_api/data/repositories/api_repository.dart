import 'package:dartz/dartz.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/pihole_api/data/models/blacklist.dart';
import 'package:flutterhole/features/pihole_api/data/models/dns_query_type.dart';
import 'package:flutterhole/features/pihole_api/data/models/forward_destinations.dart';
import 'package:flutterhole/features/pihole_api/data/models/over_time_data.dart';
import 'package:flutterhole/features/pihole_api/data/models/over_time_data_clients.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_client.dart';
import 'package:flutterhole/features/pihole_api/data/models/query_data.dart';
import 'package:flutterhole/features/pihole_api/data/models/summary.dart';
import 'package:flutterhole/features/pihole_api/data/models/top_items.dart';
import 'package:flutterhole/features/pihole_api/data/models/top_sources.dart';
import 'package:flutterhole/features/pihole_api/data/models/whitelist.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';

abstract class ApiRepository {
  Future<Either<Failure, SummaryModel>> fetchSummary(PiholeSettings settings);

  Future<Either<Failure, OverTimeData>> fetchQueriesOverTime(
      PiholeSettings settings);

  Future<Either<Failure, OverTimeDataClients>> fetchClientsOverTime(
      PiholeSettings settings);

  Future<Either<Failure, TopSourcesResult>> fetchTopSources(
      PiholeSettings settings);

  Future<Either<Failure, TopItems>> fetchTopItems(PiholeSettings settings);

  Future<Either<Failure, ForwardDestinationsResult>> fetchForwardDestinations(
      PiholeSettings settings);

  Future<Either<Failure, DnsQueryTypeResult>> fetchQueryTypes(
      PiholeSettings settings);

  Future<Either<Failure, List<QueryData>>> fetchQueriesForClient(
      PiholeSettings settings, PiClient client);

  Future<Either<Failure, List<QueryData>>> fetchQueriesForDomain(
      PiholeSettings settings, String domain);

  Future<Either<Failure, List<QueryData>>> fetchManyQueryData(
      PiholeSettings settings,
      [int maxResults]);

  Future<Either<Failure, Whitelist>> fetchWhitelist(PiholeSettings settings);

  Future<Either<Failure, Blacklist>> fetchBlacklist(PiholeSettings settings);
}
