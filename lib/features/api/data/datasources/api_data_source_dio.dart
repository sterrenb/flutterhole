import 'package:dio/dio.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/api/data/datasources/api_data_source.dart';
import 'package:flutterhole/features/api/data/models/dns_query_type.dart';
import 'package:flutterhole/features/api/data/models/over_time_data.dart';
import 'package:flutterhole/features/api/data/models/summary.dart';
import 'package:flutterhole/features/api/data/models/toggle_status.dart';
import 'package:flutterhole/features/api/data/models/top_sources.dart';
import 'package:injectable/injectable.dart';

@injectable
class ApiDataSourceDio implements ApiDataSource {
  ApiDataSourceDio([Dio dio]) : _dio = dio ?? getIt<Dio>();

  final Dio _dio;

  Future<Map<String, dynamic>> _get({
    Map<String, dynamic> queryParameters = const {},
  }) async {
    final Response response =
        await _dio.get('', queryParameters: queryParameters);

    final data = response.data;

    if (data is String) {
      if (data.isEmpty) throw EmptyResponseException();
      if (data == '[]') throw NotAuthenticatedException();
      throw MalformedResponseException();
    }

    return data;
  }

  @override
  Future<Summary> fetchSummary() async {
    final json = await _get(queryParameters: {
      'summaryRaw': '',
    });

    return Summary.fromJson(json);
  }

  @override
  Future<ToggleStatus> disablePihole(String apiToken) async {
    // TODO: implement disablePihole
    throw UnimplementedError();
  }

  @override
  Future<ToggleStatus> enablePihole(String apiToken) async {
    // TODO: implement enablePihole
    throw UnimplementedError();
  }

  @override
  Future<OverTimeData> fetchQueriesOverTime() async {
    // TODO: implement fetchQueriesOverTime
    throw UnimplementedError();
  }

  @override
  Future<DnsQueryTypeResult> fetchQueryTypes(String apiToken) async {
    // TODO: implement fetchQueryTypes
    throw UnimplementedError();
  }

  @override
  Future<TopSourcesResult> fetchTopSources(String apiToken) async {
    // TODO: implement fetchTopSources
    throw UnimplementedError();
  }

  @override
  Future<ToggleStatus> pingPihole() async {
    // TODO: implement pingPihole
    throw UnimplementedError();
  }

  @override
  Future<ToggleStatus> sleepPihole(String apiToken, Duration duration) async {
    // TODO: implement sleepPihole
    throw UnimplementedError();
  }
}
