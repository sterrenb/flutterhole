import 'package:dio/dio.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/models.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

/// The string that counts as the API token on Pi-holes
/// without authentication.
///
/// https://github.com/sterrenburg/flutterhole/issues/79
const String kNoApiTokenNeeded = 'No password set';

class PiholeRepository {
  const PiholeRepository(this.read);

  final Reader read;

  Future<dynamic> _get(
    Pi pi,
    String path,
    Map<String, dynamic> queryParameters,
  ) async {
    final dio = read(dioProvider);

    final response = await dio.get(
      path,
      queryParameters: queryParameters,
    );

    _validateData(response.data);

    return response.data;
  }

  Future<dynamic> _getSecure(
    Pi pi,
    String path,
    Map<String, dynamic> queryParameters,
  ) async {
    if (pi.apiTokenRequired && pi.apiToken.isEmpty) {
      throw PiholeApiFailure.notAuthenticated();
    }

    String apiToken = pi.apiToken;
    if (pi.apiTokenRequired == false && pi.apiToken.isEmpty) {
      apiToken = kNoApiTokenNeeded;
    }

    queryParameters.addAll({'auth': apiToken});

    return _get(pi, path, queryParameters);
  }

  void _validateData(dynamic data) {
    if (data is String && data.isEmpty) {
      throw PiholeApiFailure.emptyString();
    }

    if (data is List && data.isEmpty) {
      throw PiholeApiFailure.emptyList();
    }
  }

  PiholeApiFailure _onDioError(DioError e) {
    switch (e.type) {
      case DioErrorType.CONNECT_TIMEOUT:
      case DioErrorType.SEND_TIMEOUT:
      case DioErrorType.RECEIVE_TIMEOUT:
        return PiholeApiFailure.timeout();
      case DioErrorType.RESPONSE:
        return PiholeApiFailure.invalidResponse(e.response.statusCode);
      case DioErrorType.CANCEL:
        return PiholeApiFailure.cancelled();
      case DioErrorType.DEFAULT:
      default:
        return PiholeApiFailure.unknown(e);
    }
  }

  Future<Summary> fetchSummary(Pi pi) async {
    try {
      final data = await _get(pi, pi.baseApiUrl, {'summaryRaw': ''});
      final summary = SummaryModel.fromJson(data);
      return summary.entity;
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }

  Future<PiQueryTypes> fetchQueryTypes(Pi pi) async {
    try {
      final data = await _getSecure(pi, pi.baseApiUrl, {'getQueryTypes': ''});

      final queryTypes = PiQueryTypesModel.fromJson(data);
      return queryTypes.entity;
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }

  Future<PiForwardDestinations> fetchForwardDestinations(Pi pi) async {
    try {
      final data =
          await _getSecure(pi, pi.baseApiUrl, {'getForwardDestinations': ''});

      final forwardDestinations = PiForwardDestinationsModel.fromJson(data);
      final Map<String, double> map = Map.from(forwardDestinations.destinations)
        ..addAll({
          'testje': 12.34,
          'testje2': 12.34,
          'testje34454532453543': 12.34,
          'tesyasyayayaytje': 12.34
        });
      return PiForwardDestinations(destinations: map);
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }

  Future<PiQueriesOverTime> fetchQueriesOverTime(Pi pi) async {
    try {
      final data =
          await _getSecure(pi, pi.baseApiUrl, {'overTimeData10mins': ''});

      final queries = PiQueriesOverTimeModel.fromJson(data);
      return queries.entity;
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }

  double _docToTemperature(Document doc) =>
      double.tryParse(doc.getElementById('rawtemp').innerHtml) ?? -1;

  double _docToMemoryUsage(Document doc) {
    try {
      final string = doc.outerHtml;
      final startIndex = string.indexOf('Memory usage');
      final sub = string.substring(startIndex);
      final endIndex = sub.indexOf('</span>');
      final end = sub.substring(0, endIndex);
      final nums = end.getNumbers();
      return nums.first.toDouble();
    } catch (e) {
      return -1;
    }
  }

  List<double> _docToLoad(Document doc) => List<double>.from(doc
      .getElementsByClassName('fa fa-circle text-green-light')
      .elementAt(1)
      .parent
      .innerHtml
      .getNumbers());

  Future<PiDetails> fetchPiDetails(Pi pi) async {
    final dio = read(dioProvider);

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

  Future<PiholeStatus> enable(Pi pi) async {
    print('enabling ${pi.title}');
    try {
      final data = await _getSecure(pi, pi.baseApiUrl, {'enable': ''});

      final status = PiholeStatusModel.fromJson(data);
      print('status after enable: ${status.entity}');
      return status.entity;
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
          .map((RegExpMatch match) => num.tryParse(match.group(0)) ?? -1)
          .toList();
    else
      return [];
  }
}
