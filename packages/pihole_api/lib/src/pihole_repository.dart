import 'package:clock/clock.dart';
import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

import 'entities.dart';
import 'formatting.dart';
import 'models.dart';

/// The string that counts as the API token on Pi-holes
/// without authentication.
///
/// https://github.com/sterrenburg/flutterhole/issues/79
const String kNoApiTokenNeeded = 'No password set';

class PiholeRepository {
  const PiholeRepository(this.params);

  final PiholeRepositoryParams params;

  Future<dynamic> _get(
    Map<String, dynamic> queryParameters,
    CancelToken cancelToken,
  ) async {
    // log(LogCall(title, LogLevel.info, 'GET /${queryParameters.keys.first}'));

    final response = await params.dio.get(
      '/' + params.apiPath,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );

    final error = _validateData(response.data);
    if (error != null) throw error;

    return response.data;
  }

  Future<dynamic> _getSecure(
    Map<String, dynamic> queryParameters,
    CancelToken cancelToken,
  ) async {
    if (params.apiTokenRequired && params.apiToken.isEmpty) {
      throw PiholeApiFailure.notAuthenticated();
    }

    String apiToken = params.apiToken;
    if (params.apiTokenRequired == false && apiToken.isEmpty) {
      apiToken = kNoApiTokenNeeded;
    }

    queryParameters.addAll({'auth': apiToken});

    return _get(queryParameters, cancelToken);
  }

  PiholeApiFailure? _validateData(dynamic data) {
    if (data is String && data.isEmpty) {
      return PiholeApiFailure.emptyString();
    }

    if (data is List && data.isEmpty) {
      return PiholeApiFailure.emptyList();
    }
  }

  PiholeApiFailure _onDioError(DioError e) {
    switch (e.type) {
      case DioErrorType.connectTimeout:
      case DioErrorType.sendTimeout:
      case DioErrorType.receiveTimeout:
        return PiholeApiFailure.timeout();
      case DioErrorType.response:
        return PiholeApiFailure.invalidResponse(e.response?.statusCode ?? 500);
      case DioErrorType.cancel:
        return PiholeApiFailure.cancelled();
      case DioErrorType.other:
      default:
        if (e.message.contains('Failed host lookup')) {
          return PiholeApiFailure.hostname();
        }

        return PiholeApiFailure.general(e.message);
    }
  }

  Future<PiSummary> fetchSummary(CancelToken cancelToken) async {
    try {
      final data = await _get({'summaryRaw': ''}, cancelToken);
      final piSummary = PiSummaryModel.fromJson(data);
      return piSummary.entity;
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }

  Future<PiQueryTypes> fetchQueryTypes(CancelToken cancelToken) async {
    try {
      final data = await _getSecure({'getQueryTypes': ''}, cancelToken);

      final queryTypes = PiQueryTypesModel.fromJson(data);
      queryTypes.types.removeWhere((key, value) => value <= 0);
      return queryTypes.entity;
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }

  Future<PiForwardDestinations> fetchForwardDestinations(
      CancelToken cancelToken) async {
    try {
      final data =
          await _getSecure({'getForwardDestinations': ''}, cancelToken);

      final forwardDestinations = PiForwardDestinationsModel.fromJson(data);
      return forwardDestinations.entity;
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }

  Future<PiQueriesOverTime> fetchQueriesOverTime(
      CancelToken cancelToken) async {
    try {
      final data = await _getSecure({'overTimeData10mins': ''}, cancelToken);

      var queries = PiQueriesOverTimeModel.fromJson(data);
      return queries.entity;
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }

  Future<PiClientActivityOverTime> fetchClientActivityOverTime(
      CancelToken cancelToken) async {
    try {
      final data = await _getSecure({
        'getClientNames': '',
        'overTimeDataClients': '',
      }, cancelToken);

      var queries = PiClientsOverTimeModel.fromJson(data);
      return queries.entity;
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }

  double _docToTemperature(Document doc) {
    return double.tryParse(doc.getElementById('rawtemp')?.innerHtml ?? "") ??
        -1;
  }

  double _docToMemoryUsage(Document doc) {
    final string = doc.outerHtml;
    final startIndex = string.indexOf('usage:');
    if (startIndex < 0) return -1;

    final sub = string.substring(startIndex);
    final endIndex = sub.indexOf('</span>');
    if (endIndex < 0) return -1;

    final end = sub.substring(0, endIndex);
    final numbers = end.getNumbers();
    if (numbers.isEmpty) return -1;

    return numbers.first.toDouble();
  }

  List<double> _docToLoads(Document doc) {
    final list = doc.getElementsByClassName('fa fa-circle text-green-light');

    if (list.isEmpty) return [];

    final element = list.elementAt(1).parent;

    return List<double>.from((element?.innerHtml ?? "").getNumbers());
  }

  Future<PiDetails> fetchPiDetails(CancelToken cancelToken) async {
    try {
      final response = await params.dio.get(
        params.adminHome,
        cancelToken: cancelToken,
      );
      final data = response.data;

      if (data is String && data.isEmpty) {
        throw PiholeApiFailure.emptyString();
      }

      final Document doc = parse(data);

      return PiDetails(
        temperature: _docToTemperature(doc),
        cpuLoads: _docToLoads(doc),
        memoryUsage: _docToMemoryUsage(doc),
      );
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }

  Future<PiholeStatus> ping(CancelToken cancelToken) async {
    try {
      final data = await _get({'status': ''}, cancelToken);

      final status = PiholeStatusModel.fromJson(data);
      return status.entity;
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }

  Future<PiholeStatus> enable(CancelToken cancelToken) async {
    try {
      final data = await _getSecure({'enable': ''}, cancelToken);

      final status = PiholeStatusModel.fromJson(data);
      return status.entity;
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }

  Future<PiholeStatus> disable(CancelToken cancelToken) async {
    try {
      final data = await _getSecure({'disable': ''}, cancelToken);

      final status = PiholeStatusModel.fromJson(data);
      return status.entity;
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }

  Future<PiholeStatus> sleep(Duration duration, CancelToken cancelToken) async {
    try {
      final data =
          await _getSecure({'disable': '${duration.inSeconds}'}, cancelToken);

      final status = PiholeStatusModel.fromJson(data);
      return status.entity.maybeWhen(
        disabled: () => PiholeStatus.sleeping(duration, clock.now()),
        orElse: () => status.entity,
      );
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }

  Future<List<QueryItem>> fetchQueryItems(
      CancelToken cancelToken, int maxResults) async {
    try {
      final params = <String, dynamic>{
        'getAllQueries': maxResults.toString(),
      };
      final data = await _getSecure(params, cancelToken);
      final list = data['data'] as List<dynamic>;
      return List<QueryItem>.from(
              list.map((json) => QueryItemModel.fromList(json).entity))
          .reversed
          .toList();
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }

  Future<TopItems> fetchTopItems(CancelToken cancelToken) async {
    try {
      final data = await _getSecure({'topItems': ''}, cancelToken);

      final topItems = TopItemsModel.fromJson(data);
      return topItems.entity;
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }

  Future<PiVersions> fetchVersions(CancelToken cancelToken) async {
    try {
      final data = await _get({'versions': ''}, cancelToken);
      final versions = PiVersionsModel.fromJson(data);
      return versions.entity;
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }
}
