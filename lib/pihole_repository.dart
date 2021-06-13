import 'package:dio/dio.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/models.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

/// The string that counts as the API token on Pi-holes
/// without authentication.
///
/// https://github.com/sterrenburg/flutterhole/issues/79
const String kNoApiTokenNeeded = 'No password set';

class PiholeRepository {
  const PiholeRepository(this.dio, this.pi);

  final Dio dio;
  final Pi pi;

  Future<dynamic> _get(
    String path,
    Map<String, dynamic> queryParameters,
    CancelToken cancelToken,
  ) async {
    final response = await dio.get(
      path,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );

    final error = _validateData(response.data);
    if (error != null) throw error;

    return response.data;
  }

  Future<dynamic> _getSecure(
    String path,
    Map<String, dynamic> queryParameters,
    CancelToken cancelToken,
  ) async {
    if (pi.apiTokenRequired && pi.apiToken.isEmpty) {
      throw PiholeApiFailure.notAuthenticated();
    }

    String apiToken = pi.apiToken;
    if (pi.apiTokenRequired == false && pi.apiToken.isEmpty) {
      apiToken = kNoApiTokenNeeded;
    }

    queryParameters.addAll({'auth': apiToken});

    return _get(path, queryParameters, cancelToken);
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
        return PiholeApiFailure.invalidResponse(e.response!.statusCode!);
      case DioErrorType.cancel:
        return PiholeApiFailure.cancelled();
      case DioErrorType.other:
      default:
        return PiholeApiFailure.unknown(e);
    }
  }

  Future<PiSummary> fetchPiSummary(CancelToken cancelToken) async {
    try {
      final data = await _get(pi.baseApiUrl, {'summaryRaw': ''}, cancelToken);
      final piSummary = PiSummaryModel.fromJson(data);
      return piSummary.entity;
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }

  Future<PiQueryTypes> fetchQueryTypes(CancelToken cancelToken) async {
    try {
      final data =
          await _getSecure(pi.baseApiUrl, {'getQueryTypes': ''}, cancelToken);

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
      final data = await _getSecure(
          pi.baseApiUrl, {'getForwardDestinations': ''}, cancelToken);

      final forwardDestinations = PiForwardDestinationsModel.fromJson(data);
      // final Map<String, double> map = Map.from(forwardDestinations.destinations)
      // ..addAll({
      //   'testje': 12.34,
      //   'testje2': 12.34,
      //   'testje34454532453543': 12.34,
      //   'tesyasyayayaytje': 12.34
      // })
      // ;
      return forwardDestinations.entity;
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }

  Future<PiQueriesOverTime> fetchQueriesOverTime(
      CancelToken cancelToken) async {
    try {
      final data = await _getSecure(
          pi.baseApiUrl, {'overTimeData10mins': ''}, cancelToken);

      var queries = PiQueriesOverTimeModel.fromJson(data);
      // queries = queries.copyWith(
      //     domainsOverTime: queries.domainsOverTime
      //         .map((key, value) => MapEntry(key, value * 1)));
      return queries.entity;
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }

  Future<PiClientActivityOverTime> fetchClientActivityOverTime(
      CancelToken cancelToken) async {
    try {
      final data = await _getSecure(
          pi.baseApiUrl,
          {
            'getClientNames': '',
            'overTimeDataClients': '',
          },
          cancelToken);

      var queries = PiClientsOverTimeModel.fromJson(data);
      return queries.entity;
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }

  double _docToTemperature(Document doc) {
    return double.tryParse(doc.getElementById('rawtemp')!.innerHtml) ?? -1;
  }

  double _docToMemoryUsage(Document doc) {
    try {
      final string = doc.outerHtml;
      final startIndex = string.indexOf('Memory usage');
      final sub = string.substring(startIndex);
      final endIndex = sub.indexOf('</span>');
      final end = sub.substring(0, endIndex);
      final numbers = end.getNumbers();
      return numbers.first.toDouble();
    } catch (e) {
      return -1;
    }
  }

  List<double> _docToLoad(Document doc) {
    final element = doc
        .getElementsByClassName('fa fa-circle text-green-light')
        .elementAt(1)
        .parent;

    if (element == null) return [];

    return List<double>.from(element.innerHtml.getNumbers());
  }

  Future<PiDetails> fetchPiDetails() async {
    try {
      final response = await dio.get(pi.adminHome);
      final data = response.data;

      if (data is String && data.isEmpty) {
        throw PiholeApiFailure.emptyString();
      }

      final Document doc = parse(data);

      return PiDetails(
        temperature: _docToTemperature(doc),
        cpuLoads: _docToLoad(doc),
        memoryUsage: _docToMemoryUsage(doc),
      );
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }

  Future<PiholeStatus> ping(CancelToken cancelToken) async {
    try {
      final data = await _get(pi.baseApiUrl, {'status': ''}, cancelToken);

      final status = PiholeStatusModel.fromJson(data);
      return status.entity;
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }

  Future<PiholeStatus> enable(CancelToken cancelToken) async {
    try {
      final data = await _getSecure(pi.baseApiUrl, {'enable': ''}, cancelToken);

      final status = PiholeStatusModel.fromJson(data);
      return status.entity;
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }

  Future<PiholeStatus> disable(CancelToken cancelToken) async {
    try {
      final data =
          await _getSecure(pi.baseApiUrl, {'disable': ''}, cancelToken);

      final status = PiholeStatusModel.fromJson(data);
      return status.entity;
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }

  Future<PiholeStatus> sleep(Duration duration, CancelToken cancelToken) async {
    try {
      final data = await _getSecure(
          pi.baseApiUrl, {'disable': '${duration.inSeconds}'}, cancelToken);

      final status = PiholeStatusModel.fromJson(data);
      return status.entity.maybeWhen(
        disabled: () => PiholeStatus.sleeping(duration, DateTime.now()),
        orElse: () => status.entity,
      );
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }

  Future<List<QueryItem>> fetchQueryItems(CancelToken cancelToken,
      [int? maxResults, int? pageKey]) async {
    try {
      final params = <String, dynamic>{
        'getAllQueries': maxResults?.toString() ?? '',
        '_': pageKey ?? ''
      };
      final data = await _getSecure(pi.baseApiUrl, params, cancelToken);
      final list = data['data'] as List<dynamic>;
      return List.from(
          list.map((json) => QueryItemModel.fromList(json).entity));
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }

  // TODO add maxResults for fake pagination
  Future<TopItems> fetchTopItems(CancelToken cancelToken) async {
    try {
      final data =
          await _getSecure(pi.baseApiUrl, {'topItems': ''}, cancelToken);

      final topItems = TopItemsModel.fromJson(data);
      return topItems.entity;
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }

  Future<PiVersions> fetchVersions(CancelToken cancelToken) async {
    try {
      final data = await _get(pi.baseApiUrl, {'versions': ''}, cancelToken);
      await Future.delayed(Duration(seconds: 1));
      final versions = PiVersionsModel.fromJson(data);
      return versions.entity;
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }
}

final RegExp _numberRegex = RegExp(r'\d+.\d+');

extension StringExtension on String {
  List<num> getNumbers() {
    if (_numberRegex.hasMatch(this))
      return _numberRegex
          .allMatches(this)
          .map((RegExpMatch match) => num.tryParse(match.group(0)!) ?? -1)
          .toList();
    else
      return [];
  }
}
