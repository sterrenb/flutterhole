import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/core/debug/fixture_reader.dart';
import 'package:flutterhole/core/models/exceptions.dart';
import 'package:flutterhole/features/pihole_api/data/datasources/api_data_source_dio.dart';
import 'package:flutterhole/features/pihole_api/data/models/blacklist.dart';
import 'package:flutterhole/features/pihole_api/data/models/dns_query_type.dart';
import 'package:flutterhole/features/pihole_api/data/models/forward_destinations.dart';
import 'package:flutterhole/features/pihole_api/data/models/list_response.dart';
import 'package:flutterhole/features/pihole_api/data/models/many_query_data.dart';
import 'package:flutterhole/features/pihole_api/data/models/over_time_data.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_client.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_extras.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_versions.dart';
import 'package:flutterhole/features/pihole_api/data/models/summary.dart';
import 'package:flutterhole/features/pihole_api/data/models/toggle_status.dart';
import 'package:flutterhole/features/pihole_api/data/models/top_items.dart';
import 'package:flutterhole/features/pihole_api/data/models/top_sources.dart';
import 'package:flutterhole/features/pihole_api/data/models/whitelist.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:mockito/mockito.dart';
import 'package:supercharged/supercharged.dart';

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
//    dio.interceptors.add(LogInterceptor(
//      requestHeader: false,
//      responseBody: true,
//    ));
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
        final SummaryModel result =
            await apiDataSourceDio.fetchSummary(piholeSettings);
        // assert
        expect(result, equals(SummaryModel.fromJson(json)));
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

  group('fetchExtras', () {
    test('should return PiExtras on success', () async {
      // arrange
      final string = loadFileAsString('home.txt');
      stubStringResponse(string, 200);
      final expected = PiExtras(
        temperature: 51.002,
        load: [0.35, 0.45, 0.38],
        memoryUsage: 18.1,
      );
      // act
      final PiExtras result =
          await apiDataSourceDio.fetchExtras(piholeSettings);
      // assert
      expect(result, equals(expected));
    });

    test('should throw on empty response', () async {
      // arrange
      stubStringResponse('', 200);
      // act
      // assert
      expect(() => apiDataSourceDio.fetchExtras(piholeSettings),
          throwsA(EmptyResponsePiException('')));
    });
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
      'should throw $NotAuthenticatedPiException on enablePihole with empty apiToken',
      () async {
        // arrange
//        stubStringResponse('[]', 200);
        piholeSettings = piholeSettings.copyWith(apiToken: '');
        // assert
        expect(() => apiDataSourceDio.enablePihole(piholeSettings),
            throwsA(NotAuthenticatedPiException('API token is empty')));
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

    test(
      'should return $ToggleStatus.enabled on successful enablePihole with apiTokenRequired=false',
      () async {
        // arrange
        final json = stubFixtureResponse('status_enabled.json', 200);
        piholeSettings = piholeSettings.copyWith(
          apiToken: '',
          apiTokenRequired: false,
        );
        // act
        final ToggleStatus result =
            await apiDataSourceDio.enablePihole(piholeSettings);
        // assert
        expect(result, equals(ToggleStatus.fromJson(json)));
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

  test(
    'should return $ForwardDestinationsResult on successful fetchForwardDestinations',
    () async {
      // arrange
      piholeSettings = piholeSettings.copyWith(apiToken: 'token');
      final json = stubFixtureResponse('get_forward_destinations.json', 200);
      // act
      final ForwardDestinationsResult result =
          await apiDataSourceDio.fetchForwardDestinations(piholeSettings);
      // assert
      expect(result, equals(ForwardDestinationsResult.fromJson(json)));
    },
  );

  test(
    'should return $TopItems on successful fetchTopItems',
    () async {
      // arrange
      piholeSettings = piholeSettings.copyWith(apiToken: 'token');
      final json = stubFixtureResponse('top_items.json', 200);
      // act
      final TopItems result =
          await apiDataSourceDio.fetchTopItems(piholeSettings);
      // assert
      expect(result, equals(TopItems.fromJson(json)));
    },
  );

  test(
    'should return $PiVersions on successful fetchPiVersions',
    () async {
      // arrange
      piholeSettings = piholeSettings.copyWith(apiToken: 'token');
      final json = stubFixtureResponse('get_versions.json', 200);
      // act
      final PiVersions result =
          await apiDataSourceDio.fetchVersions(piholeSettings);
      // assert
      expect(result, equals(PiVersions.fromJson(json)));
    },
  );

  test(
    'should return $ManyQueryData on successful fetchQueryDataForClient with titled client',
    () async {
      // arrange
      piholeSettings = piholeSettings.copyWith(apiToken: 'token');
      final json = stubFixtureResponse('get_all_queries_10.json', 200);
      // act
      final ManyQueryData result =
          await apiDataSourceDio.fetchQueryDataForClient(
              piholeSettings,
              PiClient(
                name: 'client',
                ip: '1.2.3.4',
              ));
      // assert
      expect(result, equals(ManyQueryData.fromJson(json)));
    },
  );

  test(
    'should return $ManyQueryData on successful fetchQueryDataForClient with titleless client',
    () async {
      // arrange
      piholeSettings = piholeSettings.copyWith(apiToken: 'token');
      final json = stubFixtureResponse('get_all_queries_10.json', 200);
      // act
      final ManyQueryData result = await apiDataSourceDio
          .fetchQueryDataForClient(piholeSettings, PiClient(ip: '1.2.3.4'));
      // assert
      expect(result, equals(ManyQueryData.fromJson(json)));
    },
  );

  test(
    'should return $ManyQueryData on successful fetchQueryDataForDomain',
    () async {
      // arrange
      piholeSettings = piholeSettings.copyWith(apiToken: 'token');
      final json = stubFixtureResponse('get_all_queries_10.json', 200);
      // act
      final ManyQueryData result = await apiDataSourceDio
          .fetchQueryDataForDomain(piholeSettings, 'example.com');
      // assert
      expect(result, equals(ManyQueryData.fromJson(json)));
    },
  );

  test(
    'should return $ManyQueryData on successful fetchManyQueryData without maxResult',
    () async {
      // arrange
      piholeSettings = piholeSettings.copyWith(apiToken: 'token');
      final json = stubFixtureResponse('get_all_queries_10.json', 200);
      // act
      final ManyQueryData result =
          await apiDataSourceDio.fetchManyQueryData(piholeSettings);
      // assert
      expect(result, equals(ManyQueryData.fromJson(json)));
    },
  );

  test(
    'should return $ManyQueryData on successful fetchManyQueryData with maxResult',
    () async {
      // arrange
      piholeSettings = piholeSettings.copyWith(apiToken: 'token');
      final json = stubFixtureResponse('get_all_queries_10.json', 200);
      // act
      final ManyQueryData result =
          await apiDataSourceDio.fetchManyQueryData(piholeSettings, 123);
      // assert
      expect(result, equals(ManyQueryData.fromJson(json)));
    },
  );

  test(
    'should return $Whitelist on successful fetchWhitelist',
    () async {
      // arrange
      piholeSettings = piholeSettings.copyWith(apiToken: 'token');
      final json = stubFixtureResponse('whitelist.json', 200);
      // act
      final Whitelist result =
          await apiDataSourceDio.fetchWhitelist(piholeSettings);
      // assert
      expect(result, equals(Whitelist.fromJson(json)));
    },
  );

  test(
    'should return $Whitelist on successful fetchRegexWhitelist',
    () async {
      // arrange
      piholeSettings = piholeSettings.copyWith(apiToken: 'token');
      final json = stubFixtureResponse('whitelist.json', 200);
      // act
      final Whitelist result =
          await apiDataSourceDio.fetchRegexWhitelist(piholeSettings);
      // assert
      expect(result, equals(Whitelist.fromJson(json)));
    },
  );

  test(
    'should return $Blacklist on successful fetchBlacklist',
    () async {
      // arrange
      piholeSettings = piholeSettings.copyWith(apiToken: 'token');
      final json = stubFixtureResponse('blacklist.json', 200);
      // act
      final Blacklist result =
          await apiDataSourceDio.fetchBlacklist(piholeSettings);
      // assert
      expect(result, equals(Blacklist.fromJson(json)));
    },
  );

  test(
    'should return $Blacklist on successful fetchRegexBlacklist',
    () async {
      // arrange
      piholeSettings = piholeSettings.copyWith(apiToken: 'token');
      final json = stubFixtureResponse('blacklist.json', 200);
      // act
      final Blacklist result =
          await apiDataSourceDio.fetchRegexBlacklist(piholeSettings);
      // assert
      expect(result, equals(Blacklist.fromJson(json)));
    },
  );

  group('list edits', () {
    test(
      'should return $ListResponse on successful addToWhitelist',
      () async {
        // arrange
        piholeSettings = piholeSettings.copyWith(apiToken: 'token');
        final json = stubFixtureResponse('list_response.json', 200);
        // act
        final ListResponse result = await apiDataSourceDio.addToWhitelist(
            piholeSettings, 'domain', false);
        // assert
        expect(result, equals(ListResponse.fromJson(json)));
      },
    );

    test(
      'should return $ListResponse on successful removeFromWhitelist',
      () async {
        // arrange
        piholeSettings = piholeSettings.copyWith(apiToken: 'token');
        final json = stubFixtureResponse('list_response.json', 200);
        // act
        final ListResponse result = await apiDataSourceDio.removeFromWhitelist(
            piholeSettings, 'domain', false);
        // assert
        expect(result, equals(ListResponse.fromJson(json)));
      },
    );

    test(
      'should return $ListResponse on successful addToRegexWhitelist',
      () async {
        // arrange
        piholeSettings = piholeSettings.copyWith(apiToken: 'token');
        final json = stubFixtureResponse('list_response.json', 200);
        // act
        final ListResponse result = await apiDataSourceDio.addToWhitelist(
            piholeSettings, 'domain', true);
        // assert
        expect(result, equals(ListResponse.fromJson(json)));
      },
    );

    test(
      'should return $ListResponse on successful removeFromRegexWhitelist',
      () async {
        // arrange
        piholeSettings = piholeSettings.copyWith(apiToken: 'token');
        final json = stubFixtureResponse('list_response.json', 200);
        // act
        final ListResponse result = await apiDataSourceDio.removeFromWhitelist(
            piholeSettings, 'domain', true);
        // assert
        expect(result, equals(ListResponse.fromJson(json)));
      },
    );

    test(
      'should return $ListResponse on successful addToBlacklist',
      () async {
        // arrange
        piholeSettings = piholeSettings.copyWith(apiToken: 'token');
        final json = stubFixtureResponse('list_response.json', 200);
        // act
        final ListResponse result = await apiDataSourceDio.addToBlacklist(
            piholeSettings, 'domain', false);
        // assert
        expect(result, equals(ListResponse.fromJson(json)));
      },
    );

    test(
      'should return $ListResponse on successful removeFromBlacklist',
      () async {
        // arrange
        piholeSettings = piholeSettings.copyWith(apiToken: 'token');
        final json = stubFixtureResponse('list_response.json', 200);
        // act
        final ListResponse result = await apiDataSourceDio.removeFromBlacklist(
            piholeSettings, 'domain', false);
        // assert
        expect(result, equals(ListResponse.fromJson(json)));
      },
    );
    test(
      'should return $ListResponse on successful addToRegexBlacklist',
      () async {
        // arrange
        piholeSettings = piholeSettings.copyWith(apiToken: 'token');
        final json = stubFixtureResponse('list_response.json', 200);
        // act
        final ListResponse result = await apiDataSourceDio.addToBlacklist(
            piholeSettings, 'domain', true);
        // assert
        expect(result, equals(ListResponse.fromJson(json)));
      },
    );

    test(
      'should return $ListResponse on successful removeFromRegexBlacklist',
      () async {
        // arrange
        piholeSettings = piholeSettings.copyWith(apiToken: 'token');
        final json = stubFixtureResponse('list_response.json', 200);
        // act
        final ListResponse result = await apiDataSourceDio.removeFromBlacklist(
            piholeSettings, 'domain', true);
        // assert
        expect(result, equals(ListResponse.fromJson(json)));
      },
    );
  });
}
