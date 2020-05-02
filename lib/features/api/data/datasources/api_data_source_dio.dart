import 'package:dio/dio.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/api/data/datasources/api_data_source.dart';
import 'package:flutterhole/features/api/data/models/dns_query_type.dart';
import 'package:flutterhole/features/api/data/models/over_time_data.dart';
import 'package:flutterhole/features/api/data/models/summary.dart';
import 'package:flutterhole/features/api/data/models/toggle_status.dart';
import 'package:flutterhole/features/api/data/models/top_sources.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:injectable/injectable.dart';

@prod
@injectable
@RegisterAs(ApiDataSource)
class ApiDataSourceDio implements ApiDataSource {
  ApiDataSourceDio([Dio dio]) : _dio = dio ?? getIt<Dio>();

  final Dio _dio;

  Future<dynamic> _get(
    PiholeSettings settings, {
    Map<String, dynamic> queryParameters = const {},
  }) async {
    try {
      final Response response =
          await _dio.get('', queryParameters: queryParameters);
      final data = response.data;

      if (data is String) {
        if (data.isEmpty) throw EmptyResponseException();
      }

      if (data is List && data.isEmpty) {
        throw EmptyResponseException();
      }

      return data;
    } on DioError catch (_) {
      throw MalformedResponseException();
    }
  }

  Future<dynamic> _getSecure(
    PiholeSettings settings, {
    Map<String, dynamic> queryParameters = const {},
  }) async {
    if (settings.apiToken.isEmpty) throw NotAuthenticatedException();

    queryParameters.addAll({'auth': settings.apiToken});

    try {
      final result = await _get(settings, queryParameters: queryParameters);
      return result;
    } on EmptyResponseException catch (_) {
      throw NotAuthenticatedException();
    }
  }

  @override
  Future<Summary> fetchSummary(PiholeSettings settings) async {
    final Map<String, dynamic> json = await _get(settings, queryParameters: {
      'summaryRaw': '',
    });

    return Summary.fromJson(json);
  }

  @override
  Future<ToggleStatus> pingPihole(PiholeSettings settings) async {
    final Map<String, dynamic> json = await _get(settings, queryParameters: {
      'status': '',
    });

    return ToggleStatus.fromJson(json);
  }

  @override
  Future<ToggleStatus> enablePihole(PiholeSettings settings) async {
    final Map<String, dynamic> json =
        await _getSecure(settings, queryParameters: {
      'enable': '',
    });

    return ToggleStatus.fromJson(json);
  }

  @override
  Future<ToggleStatus> disablePihole(PiholeSettings settings) async {
    // TODO: implement disablePihole
    throw UnimplementedError();
  }

  @override
  Future<OverTimeData> fetchQueriesOverTime(PiholeSettings settings) async {
    // TODO: implement fetchQueriesOverTime
    throw UnimplementedError();
  }

  @override
  Future<DnsQueryTypeResult> fetchQueryTypes(PiholeSettings settings) async {
    // TODO: implement fetchQueryTypes
    throw UnimplementedError();
  }

  @override
  Future<TopSourcesResult> fetchTopSources(PiholeSettings settings) async {
    // TODO: implement fetchTopSources
    throw UnimplementedError();
  }

  @override
  Future<ToggleStatus> sleepPihole(
      PiholeSettings settings, Duration duration) async {
    // TODO: implement sleepPihole
    throw UnimplementedError();
  }
}
