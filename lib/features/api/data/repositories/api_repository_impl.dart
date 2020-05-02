import 'package:dartz/dartz.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/api/data/datasources/api_data_source.dart';
import 'package:flutterhole/features/api/data/models/dns_query_type.dart';
import 'package:flutterhole/features/api/data/models/over_time_data.dart';
import 'package:flutterhole/features/api/data/models/summary.dart';
import 'package:flutterhole/features/api/data/models/toggle_status.dart';
import 'package:flutterhole/features/api/data/models/top_sources.dart';
import 'package:flutterhole/features/api/data/repositories/api_repository.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:injectable/injectable.dart';

@prod
@injectable
@RegisterAs(ApiRepository)
class ApiRepositoryImpl implements ApiRepository {
  ApiRepositoryImpl([ApiDataSource apiDataSource])
      : _apiDataSource = apiDataSource ?? getIt<ApiDataSource>();

  final ApiDataSource _apiDataSource;



  @override
  Future<Either<Failure, ToggleStatus>> disablePihole(PiholeSettings settings) {
    // TODO: implement disablePihole
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, ToggleStatus>> enablePihole(PiholeSettings settings) {
    // TODO: implement enablePihole
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, OverTimeData>> fetchQueriesOverTime(
      PiholeSettings settings) {
    // TODO: implement fetchQueriesOverTime
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, DnsQueryTypeResult>> fetchQueryTypes(
      PiholeSettings settings) {
    // TODO: implement fetchQueryTypes
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Summary>> fetchSummary() {
    // TODO: implement fetchSummary
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, TopSourcesResult>> fetchTopSources(
      PiholeSettings settings) {
    // TODO: implement fetchTopSources
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, ToggleStatus>> pingPihole(PiholeSettings settings) {
    // TODO: implement pingPihole
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, ToggleStatus>> sleepPihole(
      PiholeSettings settings, Duration duration) {
    // TODO: implement sleepPihole
    throw UnimplementedError();
  }
}
