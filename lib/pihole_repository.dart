import 'package:dio/dio.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/models.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

class PiholeRepository {
  const PiholeRepository(this.read);

  final Reader read;

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
    final dio = read(dioProvider);

    try {
      final response = await dio.get('${pi.baseApiUrl}/summary');
      final data = response.data;

      if (data is String && data.isEmpty) {
        return throw PiholeApiFailure.emptyString();
      }

      if (data is List && data.isEmpty) {
        throw PiholeApiFailure.emptyList();
      }

      final summary = SummaryModel.fromJson(data);
      return summary.entity;
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
      print('_docToMemoryUsage: $e');
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
