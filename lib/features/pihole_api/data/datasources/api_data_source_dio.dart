import 'dart:convert';
import 'dart:io';

import 'package:alice/alice.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutterhole/core/models/exceptions.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/pihole_api/data/datasources/api_data_source.dart';
import 'package:flutterhole/features/pihole_api/data/models/dns_query_type.dart';
import 'package:flutterhole/features/pihole_api/data/models/forward_destinations.dart';
import 'package:flutterhole/features/pihole_api/data/models/many_query_data.dart';
import 'package:flutterhole/features/pihole_api/data/models/over_time_data.dart';
import 'package:flutterhole/features/pihole_api/data/models/over_time_data_clients.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_client.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_versions.dart';
import 'package:flutterhole/features/pihole_api/data/models/summary.dart';
import 'package:flutterhole/features/pihole_api/data/models/toggle_status.dart';
import 'package:flutterhole/features/pihole_api/data/models/top_items.dart';
import 'package:flutterhole/features/pihole_api/data/models/top_sources.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:injectable/injectable.dart';

@prod
@Injectable(as: ApiDataSource)
class ApiDataSourceDio implements ApiDataSource {
  ApiDataSourceDio([Dio dio, Alice alice])
      : _dio = dio ?? getIt<Dio>(),
        _alice = alice ?? getIt<Alice>() {
    _dio.interceptors.add(_alice.getDioInterceptor());
  }

  final Dio _dio;
  final Alice _alice;

  Future<dynamic> _get(
    PiholeSettings settings, {
    Map<String, dynamic> queryParameters = const {},
  }) async {
    if (settings.allowSelfSignedCertificates) {
      // https://github.com/flutterchina/dio/issues/32#issuecomment-487401443
      (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }

    Map<String, String> headers = {
      HttpHeaders.userAgentHeader: "flutterhole",
      HttpHeaders.contentTypeHeader: Headers.jsonContentType,
    };

    if (settings.basicAuthenticationUsername.isNotEmpty ||
        settings.basicAuthenticationPassword.isNotEmpty) {
      String basicAuth = 'Basic ' +
          base64Encode(utf8.encode(
              '${settings.basicAuthenticationUsername}:${settings.basicAuthenticationPassword}'));

      headers.putIfAbsent(HttpHeaders.authorizationHeader, () => basicAuth);
    }

    try {
      final url = '${settings.baseUrl}:${settings.apiPort}${settings.apiPath}';

      final Response response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
        ),
      );

      final data = response.data;

      if (data is String) {
        if (data.isEmpty) throw EmptyResponsePiException(data);
      }

      if (data is List && data.isEmpty) {
        throw EmptyResponsePiException(data);
      }

      return data;
    } on DioError catch (e) {
      switch (e.type) {
        case DioErrorType.CONNECT_TIMEOUT:
        case DioErrorType.SEND_TIMEOUT:
        case DioErrorType.RECEIVE_TIMEOUT:
          throw TimeOutPiException(e);
        case DioErrorType.RESPONSE:
          throw NotFoundPiException(e);
        case DioErrorType.CANCEL:
        case DioErrorType.DEFAULT:
        default:
          switch (e.response?.statusCode ?? 0) {
            case 404:
              throw NotFoundPiException(e);
            default:
              throw MalformedResponsePiException(e);
          }
      }
    }
  }

  Future<dynamic> _getSecure(
    PiholeSettings settings, {
    Map<String, dynamic> queryParameters = const {},
  }) async {
    String apiToken = settings.apiToken;

    if (settings.apiTokenRequired) {
      if (apiToken.isEmpty)
        throw NotAuthenticatedPiException('API token is empty');
    } else {
      apiToken = kNoApiTokenNeeded;
    }

    queryParameters.addAll({'auth': apiToken});

    try {
      final result = await _get(settings, queryParameters: queryParameters);
      return result;
    } on EmptyResponsePiException catch (e) {
      throw NotAuthenticatedPiException(e);
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
  Future<OverTimeDataClients> fetchClientsOverTime(
      PiholeSettings settings) async {
    final Map<String, dynamic> json =
        await _getSecure(settings, queryParameters: {
      'getClientNames': '',
      'overTimeDataClients': '',
    });

    return OverTimeDataClients.fromJson(json);
  }

  @override
  Future<TopSourcesResult> fetchTopSources(PiholeSettings settings) async {
    final Map<String, dynamic> json =
        await _getSecure(settings, queryParameters: {
      'getQuerySources': '',
    });

    return TopSourcesResult.fromJson(json);
  }

  @override
  Future<TopItems> fetchTopItems(PiholeSettings settings) async {
    final Map<String, dynamic> json = await _getSecure(
      settings,
      queryParameters: {
        'topItems': '',
      },
    );

    return TopItems.fromJson(json);
  }

  @override
  Future<ForwardDestinationsResult> fetchForwardDestinations(
      PiholeSettings settings) async {
    final Map<String, dynamic> json =
        await _getSecure(settings, queryParameters: {
      'getForwardDestinations': '',
    });

    return ForwardDestinationsResult.fromJson(json);
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
  Future<PiVersions> fetchVersions(PiholeSettings settings) async {
    final Map<String, dynamic> json = await _get(settings, queryParameters: {
      'versions': '',
    });

    return PiVersions.fromJson(json);
  }

  @override
  Future<ManyQueryData> fetchQueryDataForClient(
    PiholeSettings settings,
    PiClient client,
  ) async {
    final Map<String, dynamic> json =
        await _getSecure(settings, queryParameters: {
      'getAllQueries': '',
      'client': (client.name != null && client.name.isNotEmpty)
          ? client.name.trim()
          : client.ip,
    });

    return ManyQueryData.fromJson(json);
  }

  @override
  Future<ManyQueryData> fetchQueryDataForDomain(
    PiholeSettings settings,
    String domain,
  ) async {
    final Map<String, dynamic> json =
    await _getSecure(settings, queryParameters: {
      'getAllQueries': '',
      'domain': '${domain?.trim()}',
    });

    return ManyQueryData.fromJson(json);
  }

  @override
  Future<ManyQueryData> fetchManyQueryData(PiholeSettings settings,
      [int maxResults]) async {
    final Map<String, dynamic> json =
    await _getSecure(settings, queryParameters: {
      'getAllQueries': '${maxResults ?? ''}',
    });

    return ManyQueryData.fromJson(json);
  }
}
