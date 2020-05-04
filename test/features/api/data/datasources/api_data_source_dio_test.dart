import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/core/models/exceptions.dart';
import 'package:flutterhole/features/api/data/datasources/api_data_source_dio.dart';
import 'package:flutterhole/features/api/data/models/dns_query_type.dart';
import 'package:flutterhole/features/api/data/models/over_time_data.dart';
import 'package:flutterhole/features/api/data/models/summary.dart';
import 'package:flutterhole/features/api/data/models/toggle_status.dart';
import 'package:flutterhole/features/api/data/models/top_sources.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:mockito/mockito.dart';
import 'package:supercharged/supercharged.dart';

import '../../../../fixture_reader.dart';
import '../../../../test_dependency_injection.dart';

class MockHttpClientAdapter extends Mock implements HttpClientAdapter {}

HttpClientAdapter httpClientAdapterMock;

void stubStringResponse(String data, int statusCode) {
  when(httpClientAdapterMock.fetch(any, any, any))
      .thenAnswer((_) async => ResponseBody.fromString(
            data,
            statusCode,
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
  await setUpAllForTest();

  ApiDataSourceDio apiDataSourceDio;
  Dio dio;
  PiholeSettings piholeSettings;


  setUp(() {
    httpClientAdapterMock = MockHttpClientAdapter();
    dio = Dio();
    dio.options.baseUrl = 'http://example.com';
    dio.interceptors.add(LogInterceptor(
      requestHeader: false,
      responseBody: true,
    ));
    piholeSettings = PiholeSettings(baseUrl: 'http://example.com');
    dio.httpClientAdapter = httpClientAdapterMock;
    apiDataSourceDio = ApiDataSourceDio(dio);
  });

  group('fetchSummary', () {
    test(
      'should return Summary on successful fetchSummary',
      () async {
        // arrange
        final json = stubFixtureResponse('summary_raw.json', 200);
        // act
        final Summary result =
            await apiDataSourceDio.fetchSummary(piholeSettings);
        // assert
        expect(result, equals(Summary.fromJson(json)));
      },
    );

    test(
      'should throw EmptyResponsePiException on empty Json response',
      () async {
        // arrange
        stubStringResponse('', 200);
        // assert
        expect(() => apiDataSourceDio.fetchSummary(piholeSettings),
            throwsA(isA<EmptyResponsePiException>()));
      },
    );

    test(
      'should throw $EmptyResponsePiException on empty Json list response',
      () async {
        // arrange
        stubStringResponse('[]', 200);
        // assert
        expect(() => apiDataSourceDio.fetchSummary(piholeSettings),
            throwsA(isA<EmptyResponsePiException>()));
      },
    );

    test(
      'should throw $NotFoundPiException on 404 empty json response',
      () async {
        // arrange
        stubStringResponse('{}', 404);
        // assert
        expect(() => apiDataSourceDio.fetchSummary(piholeSettings),
            throwsA(isA<NotFoundPiException>()));
      },
    );

    test(
      'should throw MalformedResponsePiException on unknown String response',
      () async {
        // arrange
        stubStringResponse('hello', 200);
        // assert
        expect(() => apiDataSourceDio.fetchSummary(piholeSettings),
            throwsA(isA<MalformedResponsePiException>()));
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
        final ToggleStatus result =
            await apiDataSourceDio.pingPihole(piholeSettings);
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
        final ToggleStatus result =
            await apiDataSourceDio.pingPihole(piholeSettings);
        // assert
        expect(result, equals(ToggleStatus.fromJson(json)));
      },
    );
  });

  group('enablePihole', () {
    test(
      'should return $ToggleStatus.enabled on successful enablePihole',
      () async {
        // arrange
        final json = stubFixtureResponse('status_enabled.json', 200);
        piholeSettings = piholeSettings.copyWith(apiToken: 'token');
        // act
        final ToggleStatus result =
            await apiDataSourceDio.enablePihole(piholeSettings);
        // assert
        expect(result, equals(ToggleStatus.fromJson(json)));
      },
    );

    test(
      'should throw $NotAuthenticatedPiException on enablePihole without apiToken',
      () async {
        // arrange
        stubStringResponse('[]', 200);
        piholeSettings = piholeSettings.copyWith(apiToken: '');
        // assert
        expect(() => apiDataSourceDio.enablePihole(piholeSettings),
            throwsA(isA<NotAuthenticatedPiException>()));
      },
    );

    test(
      'should throw $NotAuthenticatedPiException on enablePihole with invalid apiToken',
      () async {
        // arrange
        stubStringResponse('[]', 200);
        piholeSettings = piholeSettings.copyWith(apiToken: 'invalid');
        // assert
        expect(() => apiDataSourceDio.enablePihole(piholeSettings),
            throwsA(isA<NotAuthenticatedPiException>()));
      },
    );
  });

  test(
    'should return $ToggleStatus.disabled on successful disablePihole',
    () async {
      // arrange
      final json = stubFixtureResponse('status_disabled.json', 200);
      piholeSettings = piholeSettings.copyWith(apiToken: 'token');
      // act
      final ToggleStatus result =
          await apiDataSourceDio.disablePihole(piholeSettings);
      // assert
      expect(result, equals(ToggleStatus.fromJson(json)));
    },
  );

  test(
    'should return $ToggleStatus.disabled on successful sleepPihole',
    () async {
      // arrange
      final json = stubFixtureResponse('status_disabled.json', 200);
      piholeSettings = piholeSettings.copyWith(apiToken: 'token');
      // act
      final ToggleStatus result =
          await apiDataSourceDio.sleepPihole(piholeSettings, 10.seconds);
      // assert
      expect(result, equals(ToggleStatus.fromJson(json)));
    },
  );

  test(
    'should return $OverTimeData on successful fetchQueriesOverTime',
    () async {
      // arrange
      final json = stubFixtureResponse('over_time_data_10mins.json', 200);
      // act
      final OverTimeData result =
          await apiDataSourceDio.fetchQueriesOverTime(piholeSettings);
      // assert
      expect(result, equals(OverTimeData.fromJson(json)));
    },
  );

  test(
    'should return $DnsQueryTypeResult on successful fetchQueryTypes',
    () async {
      // arrange
      piholeSettings = piholeSettings.copyWith(apiToken: 'token');
      final json = stubFixtureResponse('get_query_types.json', 200);
      // act
      final DnsQueryTypeResult result =
          await apiDataSourceDio.fetchQueryTypes(piholeSettings);
      // assert
      expect(result, equals(DnsQueryTypeResult.fromJson(json)));
    },
  );

  test(
    'should return $TopSourcesResult on successful fetchTopSources',
        () async {
      // arrange
      piholeSettings = piholeSettings.copyWith(apiToken: 'token');
      final json = stubFixtureResponse('get_query_sources.json', 200);
      // act
      final TopSourcesResult result =
      await apiDataSourceDio.fetchTopSources(piholeSettings);
      // assert
      expect(result, equals(TopSourcesResult.fromJson(json)));
    },
  );
}
