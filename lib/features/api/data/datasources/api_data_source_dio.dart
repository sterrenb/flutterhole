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

  Future<dynamic> _get({
    Map<String, dynamic> queryParameters = const {},
  }) async {
    try {
      final Response response =
          await _dio.get('', queryParameters: queryParameters);
      final data = response.data;

      if (data is String) {
        if (data.isEmpty) throw EmptyResponseException();
      }

      if (data is List) {
        if (data.isEmpty) throw EmptyResponseException();
      }

      return data;
    } on DioError catch (_) {
      throw MalformedResponseException();
    }
  }

  @override
  Future<Summary> fetchSummary() async {
    final Map<String, dynamic> json = await _get(queryParameters: {
      'summaryRaw': '',
    });

    return Summary.fromJson(json);
  }

  @override
  Future<ToggleStatus> pingPihole() async {
    final Map<String, dynamic> json = await _get(queryParameters: {
      'status': '',
    });

    return ToggleStatus.fromJson(json);
  }

  @override
  Future<ToggleStatus> enablePihole() async {
    final Map<String, dynamic> json = await _get(queryParameters: {
      'enable': '',
    });

    return ToggleStatus.fromJson(json);
  }

  @override
  Future<ToggleStatus> disablePihole() async {
    // TODO: implement disablePihole
    throw UnimplementedError();
  }

  @override
  Future<OverTimeData> fetchQueriesOverTime() async {
    // TODO: implement fetchQueriesOverTime
    throw UnimplementedError();
  }

  @override
  Future<DnsQueryTypeResult> fetchQueryTypes() async {
    // TODO: implement fetchQueryTypes
    throw UnimplementedError();
  }

  @override
  Future<TopSourcesResult> fetchTopSources() async {
    // TODO: implement fetchTopSources
    throw UnimplementedError();
  }

  @override
  Future<ToggleStatus> sleepPihole(Duration duration) async {
    // TODO: implement sleepPihole
    throw UnimplementedError();
  }
}
