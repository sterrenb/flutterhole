import 'package:dartz/dartz.dart';
import 'package:flutterhole/core/models/exceptions.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/api/data/datasources/api_data_source.dart';
import 'package:flutterhole/features/api/data/models/dns_query_type.dart';
import 'package:flutterhole/features/api/data/models/forward_destinations.dart';
import 'package:flutterhole/features/api/data/models/over_time_data.dart';
import 'package:flutterhole/features/api/data/models/summary.dart';
import 'package:flutterhole/features/api/data/models/toggle_status.dart';
import 'package:flutterhole/features/api/data/models/top_sources.dart';
import 'package:flutterhole/features/api/data/repositories/api_repository.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:injectable/injectable.dart';

@prod
@singleton
@RegisterAs(ApiRepository)
class ApiRepositoryImpl implements ApiRepository {
  ApiRepositoryImpl([ApiDataSource apiDataSource])
      : _apiDataSource = apiDataSource ?? getIt<ApiDataSource>();

  final ApiDataSource _apiDataSource;

  /// Wrapper for accessing simple [ApiDataSource] methods.
  Future<Either<Failure, T>> _simpleFetch<T>(
    PiholeSettings settings,
    Function dataSourceMethod,
    String description,
  ) async {
    try {
      final T result = await dataSourceMethod(settings);
      return Right(result);
    } on PiException catch (e) {
      return Left(Failure('$description failed', e));
    }
  }

  @override
  Future<Either<Failure, SummaryModel>> fetchSummary(
          PiholeSettings settings) async =>
      _simpleFetch<SummaryModel>(
        settings,
        _apiDataSource.fetchSummary,
        'fetchSummary',
      );

  @override
  Future<Either<Failure, ToggleStatus>> pingPihole(
          PiholeSettings settings) async =>
      _simpleFetch<ToggleStatus>(
        settings,
        _apiDataSource.pingPihole,
        'pingPihole',
      );

  @override
  Future<Either<Failure, ToggleStatus>> enablePihole(
          PiholeSettings settings) async =>
      _simpleFetch<ToggleStatus>(
        settings,
        _apiDataSource.enablePihole,
        'enablePihole',
      );

  @override
  Future<Either<Failure, ToggleStatus>> disablePihole(
          PiholeSettings settings) async =>
      _simpleFetch<ToggleStatus>(
        settings,
        _apiDataSource.disablePihole,
        'disablePihole',
      );

  @override
  Future<Either<Failure, ToggleStatus>> sleepPihole(
      PiholeSettings settings, Duration duration) async {
    try {
      final ToggleStatus result =
          await _apiDataSource.sleepPihole(settings, duration);
      return Right(result);
    } on PiException catch (e) {
      return Left(Failure('sleepPihole failed', e));
    }
  }

  @override
  Future<Either<Failure, OverTimeData>> fetchQueriesOverTime(
          PiholeSettings settings) async =>
      _simpleFetch<OverTimeData>(
        settings,
        _apiDataSource.fetchQueriesOverTime,
        'fetchQueriesOverTime',
      );

  @override
  Future<Either<Failure, TopSourcesResult>> fetchTopSources(
          PiholeSettings settings) async =>
      _simpleFetch<TopSourcesResult>(
        settings,
        _apiDataSource.fetchTopSources,
        'fetchTopSources',
      );

  @override
  Future<Either<Failure, ForwardDestinationsResult>> fetchForwardDestinations(
      PiholeSettings settings) async =>
      _simpleFetch<ForwardDestinationsResult>(
        settings,
        _apiDataSource.fetchForwardDestinations,
        'fetchForwardDestinations',
      );

  @override
  Future<Either<Failure, DnsQueryTypeResult>> fetchQueryTypes(
          PiholeSettings settings) async =>
      _simpleFetch<DnsQueryTypeResult>(
        settings,
        _apiDataSource.fetchQueryTypes,
        'fetchQueryTypes',
      );
}
