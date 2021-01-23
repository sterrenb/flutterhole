import 'package:dio/dio.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/models.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:hooks_riverpod/all.dart';

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

      print('data: $data');
      final summary = SummaryModel.fromJson(data);
      return summary.entity;
    } on DioError catch (e) {
      throw _onDioError(e);
    }
  }
}

final summaryProvider = FutureProvider<Summary>((ref) async {
  final api = ref.read(piholeRepositoryProvider);
  final pi = ref.watch(activePiProvider).state;

  print('fetching for ${pi.baseApiUrl}');

  return api.fetchSummary(pi);
});

final totalQueriesProvider = Provider((ref) =>
    ref.watch(summaryProvider).whenData((value) => value.dnsQueriesToday));
