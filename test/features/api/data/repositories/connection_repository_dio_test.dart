import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/core/models/exceptions.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/api/data/datasources/api_data_source.dart';
import 'package:flutterhole/features/api/data/models/dns_query_type.dart';
import 'package:flutterhole/features/api/data/models/pi_status.dart';
import 'package:flutterhole/features/api/data/models/toggle_status.dart';
import 'package:flutterhole/features/api/data/repositories/connection_repository_dio.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:mockito/mockito.dart';

import '../../../../test_dependency_injection.dart';

class MockApiDataSource extends Mock implements ApiDataSource {}

class MockHttpClientAdapter extends Mock implements HttpClientAdapter {}

HttpClientAdapter httpClientAdapterMock;

void stubStringResponse(String data, int statusCode) {
  when(httpClientAdapterMock.fetch(any, any, any))
      .thenAnswer((_) async => ResponseBody.fromString(data, statusCode));
}

void main() async {
  await setUpAllForTest();

  ApiDataSource mockApiDataSource;
  Dio dio;
  PiholeSettings tSettings;

  ConnectionRepositoryDio connectionRepositoryDio;

  setUp(() {
    httpClientAdapterMock = MockHttpClientAdapter();
    mockApiDataSource = MockApiDataSource();
    dio = Dio();
    dio.httpClientAdapter = httpClientAdapterMock;
    dio.interceptors.add(LogInterceptor(
      requestHeader: false,
      responseBody: true,
    ));
    tSettings = PiholeSettings(baseUrl: 'http://example.com');
    connectionRepositoryDio = ConnectionRepositoryDio(dio, mockApiDataSource);
  });

  group('fetchHostStatusCode', () {
    test(
      'should return 200 when host responds with 200 HTTP response',
      () async {
        // arrange
        stubStringResponse('hello', 200);
        // act
        final result =
            await connectionRepositoryDio.fetchHostStatusCode(tSettings);
        // assert
        expect(result, equals(Right(200)));
      },
    );

    test(
      'should return 404 when host responds with empty 404 HTTP response',
      () async {
        // arrange
        stubStringResponse('', 404);
        // act
        final result =
            await connectionRepositoryDio.fetchHostStatusCode(tSettings);
        // assert
        expect(result, equals(Right(404)));
      },
    );

    test(
      'should return $Failure when baseUrl is empty',
      () async {
        // arrange
        tSettings = tSettings.copyWith(baseUrl: '');
        // act
        final result =
            await connectionRepositoryDio.fetchHostStatusCode(tSettings);
        // assert
        expect(result, equals(Left<Failure, int>(Failure('baseUrl is empty'))));
      },
    );
  });

  group('fetchPiholeStatus', () {
    test(
      'should return $PiStatusEnum on successful pingPihole',
      () async {
        // arrange
        final PiStatusEnum status = PiStatusEnum.enabled;
        when(mockApiDataSource.pingPihole(tSettings))
            .thenAnswer((_) async => ToggleStatus(status: status));
        // act
        final result =
            await connectionRepositoryDio.fetchPiholeStatus(tSettings);
        // assert
        expect(result, equals(Right(status)));
      },
    );

    test(
      'should return $Failure on exception',
      () async {
        // arrange
        final tError = PiException.timeOut();
        when(mockApiDataSource.pingPihole(tSettings)).thenThrow(tError);
        // act
        final result =
            await connectionRepositoryDio.fetchPiholeStatus(tSettings);
        // assert
        expect(
            result, equals(Left(Failure('fetchPiholeStatus failed', tError))));
      },
    );
  });

  group('fetchAuthenticatedStatus', () {
    test(
      'should return true on successful fetchQueryTypes',
      () async {
        // arrange
        when(mockApiDataSource.fetchQueryTypes(tSettings))
            .thenAnswer((_) async => DnsQueryTypeResult());
        // act
        final result =
            await connectionRepositoryDio.fetchAuthenticatedStatus(tSettings);
        // assert
        expect(result, equals(Right(true)));
      },
    );

    test(
      'should return false on failed fetchQueryTypes',
      () async {
        // arrange
        final tError = PiException.timeOut();
        when(mockApiDataSource.fetchQueryTypes(tSettings)).thenThrow(tError);
        // act
        final result =
            await connectionRepositoryDio.fetchAuthenticatedStatus(tSettings);
        // assert
        expect(result, equals(Right(false)));
      },
    );
  });
}
