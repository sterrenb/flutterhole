import 'dart:convert';

import 'package:alice/alice.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/numbers_api/data/datasources/numbers_api_data_source.dart';
import 'package:injectable/injectable.dart';

@prod
@singleton
@RegisterAs(NumbersApiDataSource)
class NumbersApiDataSourceDio implements NumbersApiDataSource {
  NumbersApiDataSourceDio([
    Dio dio,
    Alice alice,
  ])  : _dio = dio ?? getIt<Dio>(),
        _alice = alice ?? getIt<Alice>() {
    _dio.options.baseUrl = NumbersApiDataSource.baseUrl;
    _dio.interceptors.add(_alice.getDioInterceptor());

    _dio.interceptors.add(
        DioCacheManager(CacheConfig(baseUrl: NumbersApiDataSource.baseUrl))
            .interceptor);
  }

  final Dio _dio;
  final Alice _alice;

  @override
  Future<String> fetchTrivia(int integer) async {
    final response = await _dio.get(
      '${integer.toString()}',
      options: buildCacheOptions(NumbersApiDataSource.maxAge),
    );
    return response.data;
  }

  @override
  Future<Map<int, String>> fetchManyTrivia(List<int> integers) async {
    // TODO perhaps fetch separate requests for each integer.
    // This would allow for more robust caching.
    final response = await _dio.get(
      '${integers.join(',')}',
      options: buildCacheOptions(NumbersApiDataSource.maxAge),
    );

    if (response.data is String) {
      final map = Map<String, String>.from(jsonDecode(response.data));
      return map
          .map<int, String>((key, value) => MapEntry(int.tryParse(key), value));
    }

    return Map<String, String>.from(response.data)
        .map<int, String>((key, value) => MapEntry(int.tryParse(key), value));
  }
}
