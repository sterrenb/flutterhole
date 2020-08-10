import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutterhole/core/models/exceptions.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/pihole_api/data/datasources/api_data_source.dart';
import 'package:flutterhole/features/pihole_api/data/models/dns_query_type.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_status.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_versions.dart';
import 'package:flutterhole/features/pihole_api/data/models/toggle_status.dart';
import 'package:flutterhole/features/pihole_api/data/repositories/connection_repository.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:injectable/injectable.dart';

@Singleton(as: ConnectionRepository)
class ConnectionRepositoryDio implements ConnectionRepository {
  ConnectionRepositoryDio([Dio dio, ApiDataSource apiDataSource])
      : _dio = dio ?? getIt<Dio>(),
        _apiDataSource = apiDataSource ?? getIt<ApiDataSource>();

  final Dio _dio;
  final ApiDataSource _apiDataSource;

  /// Wrapper for accessing simple [ApiDataSource] methods.
  Future<Either<Failure, T>> fetchOrFailure<T>(
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
  Future<Either<Failure, int>> fetchHostStatusCode(
      PiholeSettings settings) async {
    if (settings.baseUrl?.isEmpty ?? true) {
      return Left(Failure('baseUrl is empty'));
    }

    try {
      final Response response = await _dio.get(settings.baseUrl);
      return Right(response.statusCode);
    } on DioError catch (e) {
      switch (e.type) {
        case DioErrorType.CONNECT_TIMEOUT:
        case DioErrorType.SEND_TIMEOUT:
        case DioErrorType.RECEIVE_TIMEOUT:
          return Left(Failure('timeout'));
        case DioErrorType.CANCEL:
          return Right(0);
        case DioErrorType.RESPONSE:
          return Right(e.response.statusCode);
        case DioErrorType.DEFAULT:
        default:
          return Left(Failure('dio error', e));
      }
    }
  }

  @override
  Future<Either<Failure, PiStatusEnum>> fetchPiholeStatus(
      PiholeSettings settings) async {
    try {
      final ToggleStatus result = await _apiDataSource.pingPihole(settings);
      return Right(result.status);
    } on PiException catch (e) {
      return Left(Failure('fetchPiholeStatus failed', e));
    }
  }

  @override
  Future<Either<Failure, PiVersions>> fetchVersions(
      PiholeSettings settings) async {
    try {
      final PiVersions result = await _apiDataSource.fetchVersions(settings);
      return Right(result);
    } on PiException catch (e) {
      return Left(Failure('fetchVersions failed', e));
    }
  }

  @override
  Future<Either<Failure, bool>> fetchAuthenticatedStatus(
      PiholeSettings settings) async {
    try {
      final DnsQueryTypeResult result =
          await _apiDataSource.fetchQueryTypes(settings);
      return Right(result != null);
    } on PiException catch (_) {
      return Right(false);
    }
  }

  @override
  Future<Either<Failure, ToggleStatus>> pingPihole(
          PiholeSettings settings) async =>
      fetchOrFailure<ToggleStatus>(
        settings,
        _apiDataSource.pingPihole,
        'pingPihole',
      );

  @override
  Future<Either<Failure, ToggleStatus>> enablePihole(
      PiholeSettings settings) async =>
      fetchOrFailure<ToggleStatus>(
        settings,
        _apiDataSource.enablePihole,
        'enablePihole',
      );

  @override
  Future<Either<Failure, ToggleStatus>> disablePihole(
      PiholeSettings settings) async =>
      fetchOrFailure<ToggleStatus>(
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
}
