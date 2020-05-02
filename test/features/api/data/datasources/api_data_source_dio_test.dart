import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/features/api/data/datasources/api_data_source_dio.dart';
import 'package:flutterhole/features/api/data/models/summary.dart';
import 'package:mockito/mockito.dart';

import '../../../../fixture_reader.dart';
import '../../../../test_dependency_injection.dart';

class MockHttpClientAdapter extends Mock implements HttpClientAdapter {}

void main() async {
  ApiDataSourceDio apiDataSourceDio;
  Dio dio;
  HttpClientAdapter httpClientAdapter;

  await setUpAllForTest();

  setUp(() {
    httpClientAdapter = MockHttpClientAdapter();
    dio = Dio();
    dio.httpClientAdapter = httpClientAdapter;
    apiDataSourceDio = ApiDataSourceDio(dio);
  });

  group('fetchSummary', () {
    test(
      'should return Summary on success',
      () async {
        // arrange
        final Map<String, dynamic> json = jsonFixture('summary_raw.json');
        when(httpClientAdapter.fetch(any, any, any))
            .thenAnswer((_) async => ResponseBody.fromString(
                  jsonEncode(json),
                  200,
                  headers: {
                    Headers.contentTypeHeader: [Headers.jsonContentType],
                  },
                ));
        // act
        final Summary result = await apiDataSourceDio.fetchSummary();
        // assert
        expect(result, equals(Summary.fromJson(json)));
      },
    );
  });
}
