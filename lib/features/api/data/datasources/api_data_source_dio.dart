import 'dart:io';

import 'package:alice/alice.dart';
import 'package:dio/dio.dart';
import 'package:flutterhole/core/models/exceptions.dart';
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
  ApiDataSourceDio([Dio dio, Alice alice])
      : _dio = dio ?? getIt<Dio>(),
        _alice = alice ?? getIt<Alice>() {
    _dio.interceptors.add(_alice.getDioInterceptor());
    print('interceptors: ${_dio.interceptors?.length}');
  }

  final Dio _dio;
  final Alice _alice;

  Future<dynamic> _get(
    PiholeSettings settings, {
    Map<String, dynamic> queryParameters = const {},
  }) async {
    print('getting ${settings.baseUrl} $queryParameters');

    try {
      final Response response = await _dio.get(
        '${settings.baseUrl}:${settings.apiPort}${settings.apiPath}',
        queryParameters: queryParameters,
        options: Options(
          headers: {
            HttpHeaders.userAgentHeader: "flutterhole",
          },
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
        ),
      );

      final data = response.data;

      if (data is String) {
        if (data.isEmpty) throw EmptyResponsePiException();
      }

      if (data is List && data.isEmpty) {
        throw EmptyResponsePiException();
      }

      return data;
    } on DioError catch (e) {
      switch (e.type) {
        case DioErrorType.CONNECT_TIMEOUT:
        case DioErrorType.SEND_TIMEOUT:
        case DioErrorType.RECEIVE_TIMEOUT:
          throw TimeOutPiException();
        case DioErrorType.RESPONSE:
          throw NotFoundPiException();
        case DioErrorType.CANCEL:
        case DioErrorType.DEFAULT:
        default:
          switch (e.response?.statusCode ?? 0) {
            case 404:
              throw NotFoundPiException();
            default:
              throw MalformedResponsePiException();
          }
      }
    }
  }

  Future<dynamic> _getSecure(
    PiholeSettings settings, {
    Map<String, dynamic> queryParameters = const {},
  }) async {
    if (settings.apiToken.isEmpty) throw NotAuthenticatedPiException();

    queryParameters.addAll({'auth': settings.apiToken});

    try {
      final result = await _get(settings, queryParameters: queryParameters);
      return result;
    } on EmptyResponsePiException catch (_) {
      throw NotAuthenticatedPiException();
    }
  }

  @override
  Future<SummaryModel> fetchSummary(PiholeSettings settings) async {
    final Map<String, dynamic> json = await _get(settings, queryParameters: {
      'summaryRaw': '',
    });

    return SummaryModel.fromJson(json);
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
    final Map<String, dynamic> json =
        await _getSecure(settings, queryParameters: {
      'disable': '',
    });

    return ToggleStatus.fromJson(json);
  }

  @override
  Future<ToggleStatus> sleepPihole(
      PiholeSettings settings, Duration duration) async {
    final Map<String, dynamic> json =
        await _getSecure(settings, queryParameters: {
      'disable': '${duration.inSeconds}',
    });

    return ToggleStatus.fromJson(json);
  }

  @override
  Future<OverTimeData> fetchQueriesOverTime(PiholeSettings settings) async {
    final Map<String, dynamic> json = await _get(settings, queryParameters: {
      'overTimeData10mins': '',
    });

    return OverTimeData.fromJson(json);
  }

  @override
  Future<DnsQueryTypeResult> fetchQueryTypes(PiholeSettings settings) async {
    final Map<String, dynamic> json =
        await _getSecure(settings, queryParameters: {
      'getQueryTypes': '',
    });

    return DnsQueryTypeResult.fromJson(json);
  }

  @override
  Future<TopSourcesResult> fetchTopSources(PiholeSettings settings) async {
    final Map<String, dynamic> json =
        await _getSecure(settings, queryParameters: {
      'getQuerySources': '',
    });

    return TopSourcesResult.fromJson(json);
  }
}
