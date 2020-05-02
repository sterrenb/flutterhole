import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/features/api/data/datasources/api_data_source.dart';
import 'package:flutterhole/features/api/data/datasources/api_data_source_dio.dart';
import 'package:flutterhole/features/api/data/models/summary.dart';
import 'package:flutterhole/features/api/data/models/toggle_status.dart';
import 'package:mockito/mockito.dart';

import '../../../../fixture_reader.dart';
import '../../../../test_dependency_injection.dart';

class MockHttpClientAdapter extends Mock implements HttpClientAdapter {}

HttpClientAdapter mockHttpClientAdapter;

void stubStringResponse(String data, int statusCode) {
  when(mockHttpClientAdapter.fetch(any, any, any))
      .thenAnswer((_) async => ResponseBody.fromString(
            data,
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          ));
}

Map<String, dynamic> stubFixtureResponse(String fileName, int statusCode) {
  final Map<String, dynamic> json = jsonFixture(fileName);
  stubStringResponse(jsonEncode(json), statusCode);
  return json;
}

void main() async {
  ApiDataSourceDio apiDataSourceDio;
  Dio dio;

  await setUpAllForTest();

  setUp(() {
    mockHttpClientAdapter = MockHttpClientAdapter();
    dio = Dio();
    dio.httpClientAdapter = mockHttpClientAdapter;
    apiDataSourceDio = ApiDataSourceDio(dio);
  });

  group('fetchSummary', () {
    test(
      'should return Summary on successful fetchSummary',
      () async {
        // arrange
        final json = stubFixtureResponse('summary_raw.json', 200);
        // act
        final Summary result = await apiDataSourceDio.fetchSummary();
        // assert
        expect(result, equals(Summary.fromJson(json)));
      },
    );

    test(
      'should throw EmptyResponseException on empty Json response',
      () async {
        // arrange
        stubStringResponse('', 200);
        // assert
        expect(() => apiDataSourceDio.fetchSummary(),
            throwsA(isA<EmptyResponseException>()));
      },
    );

    test(
      'should throw EmptyResponseException on empty Json list response',
      () async {
        // arrange
        stubStringResponse('[]', 200);
        // assert
        expect(() => apiDataSourceDio.fetchSummary(),
            throwsA(isA<EmptyResponseException>()));
      },
    );

    test(
      'should throw MalformedResponseException on unknown String response',
      () async {
        // arrange
        stubStringResponse('hello', 200);
        // assert
        expect(() => apiDataSourceDio.fetchSummary(),
            throwsA(isA<MalformedResponseException>()));
      },
    );
  });

  group('pingPihole', () {
    test(
      'should return ToggleStatus.enabled on successful pingPihole',
      () async {
        // arrange
        final json = stubFixtureResponse('status_enabled.json', 200);
        // act
        final ToggleStatus result = await apiDataSourceDio.pingPihole();
        // assert
        expect(result, equals(ToggleStatus.fromJson(json)));
      },
    );

    test(
      'should return ToggleStatus.disabled on successful pingPihole',
      () async {
        // arrange
        final json = stubFixtureResponse('status_disabled.json', 200);
        // act
        final ToggleStatus result = await apiDataSourceDio.pingPihole();
        // assert
        expect(result, equals(ToggleStatus.fromJson(json)));
      },
    );
  });

  test(
    'should return ToggleStatus.enabled on successful enablePihole',
        () async {
      // arrange
      final json = stubFixtureResponse('status_enabled.json', 200);
      // act
      final ToggleStatus result = await apiDataSourceDio.enablePihole();
      // assert
      expect(result, equals(ToggleStatus.fromJson(json)));
    },
  );
}
