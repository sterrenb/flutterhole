import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/core/models/exceptions.dart';
import 'package:flutterhole/features/numbers_api/data/datasources/numbers_api_data_source_dio.dart';
import 'package:mockito/mockito.dart';

import '../../../../fixture_reader.dart';
import '../../../../test_dependency_injection.dart';

class MockHttpClientAdapter extends Mock implements HttpClientAdapter {}

HttpClientAdapter httpClientAdapterMock;

void stubStringResponse(String data, int statusCode) {
  when(httpClientAdapterMock.fetch(any, any, any))
      .thenAnswer((_) async => ResponseBody.fromString(data, statusCode));
}

Map<String, dynamic> stubFixtureResponse(String fileName, int statusCode) {
  final Map<String, dynamic> json = jsonFixture(fileName);
  stubStringResponse(jsonEncode(json), statusCode);
  return json;
}

void main() async {
  await setUpAllForTest();

  NumbersApiDataSourceDio dataSource;
  Dio dio;

  setUp(() {
    httpClientAdapterMock = MockHttpClientAdapter();
    dio = Dio();
    dio.options.baseUrl = 'http://numbersapi.com/';
    dio.interceptors.add(LogInterceptor(
      requestHeader: false,
      responseBody: true,
    ));
    dio.httpClientAdapter = httpClientAdapterMock;
    dataSource = NumbersApiDataSourceDio(dio);
  });

  group('fetchTrivia', () {
//    test(
//      'should return String on successful fetchTrivia',
//      () async {
//        // arrange
//        final response = '42 is very interesting';
//        stubStringResponse(response, 200);
//        // act
//        final result = await dataSource.fetchTrivia(42);
//        // assert
//        expect(result, equals(response));
//      },
//    );

    test(
      'should throw on failed fetchTrivia',
      () async {
        // arrange
        when(httpClientAdapterMock.fetch(any, any, any))
            .thenThrow(PiException.notFound());
        // act
        // assert
        expect(() => dataSource.fetchTrivia(42), throwsA(isA<DioError>()));
      },
    );
  });

  group('fetchManyTrivia', () {
//    test(
//      'should return String on successful fetchManyTrivia',
//      () async {
//        // arrange
//        final json = stubFixtureResponse('numbers_api_many.json', 200);
//        // act
//        final result = await dataSource.fetchManyTrivia([1, 2, 3]);
//        // assert
//        expect(
//            result,
//            equals(
//                json.map((key, value) => MapEntry(int.tryParse(key), value))));
//      },
//    );

    test(
      'should throw on failed fetchManyTrivia',
      () async {
        // arrange
        when(httpClientAdapterMock.fetch(any, any, any))
            .thenThrow(PiException.notFound());
        // act
        // assert
        expect(() => dataSource.fetchManyTrivia([1, 2, 3]),
            throwsA(isA<DioError>()));
      },
    );
  });
}
