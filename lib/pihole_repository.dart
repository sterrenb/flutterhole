import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/models.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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

    final error = _validateData(response.data);
    if (error != null) throw error;

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

      print('data: ${data}');
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

  double _docToTemperature(Document doc) {
    // print(doc.getElementById('rawtemp')!.innerHtml);
    return double.tryParse(doc.getElementById('rawtemp')!.innerHtml) ?? -1;
  }

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

  List<double> _docToLoad(Document doc) {
    final element = doc
        .getElementsByClassName('fa fa-circle text-green-light')
        .elementAt(1)
        .parent;

    if (element == null) return [];

    return List<double>.from(element.innerHtml.getNumbers());
  }

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

  Future<PiholeStatus> fetchStatus(Pi pi) async {
    try {
      final data = await _get(pi, pi.baseApiUrl, {'status': ''});

      final status = PiholeStatusModel.fromJson(data);
      print('status after fetch: ${status.entity}');
      return status.entity;
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

  Future<PiholeStatus> disable(Pi pi) async {
    print('disabling ${pi.title}');
    try {
      final data = await _getSecure(pi, pi.baseApiUrl, {'disable': ''});

      final status = PiholeStatusModel.fromJson(data);
      return status.entity;
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }

  Future<PiholeStatus> sleep(Pi pi, Duration duration) async {
    print('sleeping ${pi.title}');
    try {
      final data = await _getSecure(
          pi, pi.baseApiUrl, {'disable': '${duration.inSeconds}'});

      final status = PiholeStatusModel.fromJson(data);
      return status.entity.maybeWhen(
        disabled: () => PiholeStatus.sleeping(duration, TimeOfDay.now()),
        orElse: () => status.entity,
      );
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }

  Future<List<QueryItem>> fetchQueryItems(Pi pi,
      [int? maxResults, int? pageKey]) async {
    print('fetching $maxResults from API');
    try {
      final params = <String, dynamic>{
        'getAllQueries': maxResults?.toString() ?? '',
        '_': pageKey ?? ''
      };
      print('params: $params');

      final data = await _getSecure(pi, pi.baseApiUrl, params);

      final list = data['data'] as List<dynamic>;
      print(QueryItemModel.fromList(list[0]));
      return List.from(
          list.map((json) => QueryItemModel.fromList(json).entity));
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }

  // TODO add maxResults for fake pagination
  Future<TopItems> fetchTopItems(Pi pi) async {
    try {
      final data = await _getSecure(pi, pi.baseApiUrl, {'topItems': ''});

      final topItems = TopItemsModel.fromJson(data);
      return topItems.entity;
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
