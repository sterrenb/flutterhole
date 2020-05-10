import 'dart:convert';

import 'package:alice/alice.dart';
import 'package:dio/dio.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/numbers_api/data/datasources/numbers_api_data_source.dart';
import 'package:injectable/injectable.dart';

@prod
@injectable
@RegisterAs(NumbersApiDataSource)
class NumbersApiDataSourceDio implements NumbersApiDataSource {
  NumbersApiDataSourceDio([Dio dio, Alice alice])
      : _dio = dio ?? getIt<Dio>(),
        _alice = alice ?? getIt<Alice>() {
    _dio.interceptors.add(_alice.getDioInterceptor());
  }

  final Dio _dio;
  final Alice _alice;

  @override
  Future<String> fetchTrivia(int integer) async {
    final response = await _dio.get('${integer.toString()}');
    return response.data;
  }

  @override
  Future<Map<int, String>> fetchManyTrivia(List<int> integers) async {
    final response = await _dio.get('${integers.join(',')}');

    print('data: ${response.data.runtimeType} ${response.data}');

    if (response.data is String) {
      final map = Map<String, String>.from(jsonDecode(response.data));
      return map
          .map<int, String>((key, value) => MapEntry(int.tryParse(key), value));
    }

    return response.data;
  }
}
