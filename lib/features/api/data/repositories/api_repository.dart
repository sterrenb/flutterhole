import 'package:dartz/dartz.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/api/data/models/dns_query_type.dart';
import 'package:flutterhole/features/api/data/models/over_time_data.dart';
import 'package:flutterhole/features/api/data/models/summary.dart';
import 'package:flutterhole/features/api/data/models/toggle_status.dart';
import 'package:flutterhole/features/api/data/models/top_sources.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';

abstract class ApiRepository {
  Future<Either<Failure, Summary>> fetchSummary(PiholeSettings settings);

  Future<Either<Failure, ToggleStatus>> pingPihole(PiholeSettings settings);

  Future<Either<Failure, ToggleStatus>> enablePihole(PiholeSettings settings);

  Future<Either<Failure, ToggleStatus>> disablePihole(PiholeSettings settings);

  Future<Either<Failure, ToggleStatus>> sleepPihole(
      PiholeSettings settings, Duration duration);

  Future<Either<Failure, OverTimeData>> fetchQueriesOverTime(
      PiholeSettings settings);

  Future<Either<Failure, TopSourcesResult>> fetchTopSources(
      PiholeSettings settings);

  Future<Either<Failure, DnsQueryTypeResult>> fetchQueryTypes(
      PiholeSettings settings);
}
