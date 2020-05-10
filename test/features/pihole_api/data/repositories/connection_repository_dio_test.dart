import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/core/models/exceptions.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/pihole_api/data/datasources/api_data_source.dart';
import 'package:flutterhole/features/pihole_api/data/models/dns_query_type.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_status.dart';
import 'package:flutterhole/features/pihole_api/data/models/toggle_status.dart';
import 'package:flutterhole/features/pihole_api/data/repositories/connection_repository_dio.dart';
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
  PiholeSettings settings;

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
    settings = PiholeSettings(baseUrl: 'http://example.com');
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
            await connectionRepositoryDio.fetchHostStatusCode(settings);
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
            await connectionRepositoryDio.fetchHostStatusCode(settings);
        // assert
        expect(result, equals(Right(404)));
      },
    );

    test(
      'should return $Failure when baseUrl is empty',
      () async {
        // arrange
        settings = settings.copyWith(baseUrl: '');
        // act
        final result =
            await connectionRepositoryDio.fetchHostStatusCode(settings);
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
        when(mockApiDataSource.pingPihole(settings))
            .thenAnswer((_) async => ToggleStatus(status: status));
        // act
        final result =
            await connectionRepositoryDio.fetchPiholeStatus(settings);
        // assert
        expect(result, equals(Right(status)));
      },
    );

    test(
      'should return $Failure on exception',
      () async {
        // arrange
        final tError = PiException.timeOut();
        when(mockApiDataSource.pingPihole(settings)).thenThrow(tError);
        // act
        final result =
            await connectionRepositoryDio.fetchPiholeStatus(settings);
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
        when(mockApiDataSource.fetchQueryTypes(settings))
            .thenAnswer((_) async => DnsQueryTypeResult());
        // act
        final result =
            await connectionRepositoryDio.fetchAuthenticatedStatus(settings);
        // assert
        expect(result, equals(Right(true)));
      },
    );

    test(
      'should return false on failed fetchQueryTypes',
      () async {
        // arrange
        final tError = PiException.timeOut();
        when(mockApiDataSource.fetchQueryTypes(settings)).thenThrow(tError);
        // act
        final result =
            await connectionRepositoryDio.fetchAuthenticatedStatus(settings);
        // assert
        expect(result, equals(Right(false)));
      },
    );
  });

  group('pingPihole', () {
    test(
      'should return $ToggleStatus on successful pingPihole',
          () async {
        // arrange
        final toggleStatus = ToggleStatus(status: PiStatusEnum.enabled);
        when(mockApiDataSource.pingPihole(settings))
            .thenAnswer((_) async => toggleStatus);
        // act
        final Either<Failure, ToggleStatus> result =
        await connectionRepositoryDio.pingPihole(settings);
        // assert
        expect(result, equals(Right(toggleStatus)));
      },
    );

    test(
      'should return $Failure on failed pingPihole',
          () async {
        // arrange
        final tError = PiException.emptyResponse();
        when(mockApiDataSource.pingPihole(settings)).thenThrow(tError);
        // act
        final Either<Failure, ToggleStatus> result =
        await connectionRepositoryDio.pingPihole(settings);
        // assert
        expect(result, equals(Left(Failure('pingPihole failed', tError))));
      },
    );
  });

  group('enablePihole', () {
    test(
      'should return $ToggleStatus on successful enablePihole',
          () async {
        // arrange
        final toggleStatus = ToggleStatus(status: PiStatusEnum.enabled);
        when(mockApiDataSource.enablePihole(settings))
            .thenAnswer((_) async => toggleStatus);
        // act
        final Either<Failure, ToggleStatus> result =
        await connectionRepositoryDio.enablePihole(settings);
        // assert
        expect(result, equals(Right(toggleStatus)));
      },
    );

    test(
      'should return $Failure on failed enablePihole',
          () async {
        // arrange
        final tError = PiException.emptyResponse();
        when(mockApiDataSource.enablePihole(settings)).thenThrow(tError);
        // act
        final Either<Failure, ToggleStatus> result =
        await connectionRepositoryDio.enablePihole(settings);
        // assert
        expect(result, equals(Left(Failure('enablePihole failed', tError))));
      },
    );
  });

  group('disablePihole', () {
    test(
      'should return $ToggleStatus on successful disablePihole',
          () async {
        // arrange
        final toggleStatus = ToggleStatus(status: PiStatusEnum.disabled);
        when(mockApiDataSource.disablePihole(settings))
            .thenAnswer((_) async => toggleStatus);
        // act
        final Either<Failure, ToggleStatus> result =
        await connectionRepositoryDio.disablePihole(settings);
        // assert
        expect(result, equals(Right(toggleStatus)));
      },
    );

    test(
      'should return $Failure on failed disablePihole',
          () async {
        // arrange
        final tError = PiException.emptyResponse();
        when(mockApiDataSource.disablePihole(settings)).thenThrow(tError);
        // act
        final Either<Failure, ToggleStatus> result =
        await connectionRepositoryDio.disablePihole(settings);
        // assert
        expect(result, equals(Left(Failure('disablePihole failed', tError))));
      },
    );
  });

  group('sleepPihole', () {
    test(
      'should return $ToggleStatus on successful sleepPihole',
          () async {
        // arrange
        final duration = Duration(seconds: 10);
        final toggleStatus = ToggleStatus(status: PiStatusEnum.disabled);
        when(mockApiDataSource.sleepPihole(settings, duration))
            .thenAnswer((_) async => toggleStatus);
        // act
        final Either<Failure, ToggleStatus> result =
        await connectionRepositoryDio.sleepPihole(settings, duration);
        // assert
        expect(result, equals(Right(toggleStatus)));
      },
    );

    test(
      'should return $Failure on failed sleepPihole',
          () async {
        // arrange
        final duration = Duration(seconds: 10);
        final tError = PiException.emptyResponse();
        when(mockApiDataSource.sleepPihole(settings, duration))
            .thenThrow(tError);
        // act
        final Either<Failure, ToggleStatus> result =
        await connectionRepositoryDio.sleepPihole(settings, duration);
        // assert
        expect(result, equals(Left(Failure('sleepPihole failed', tError))));
      },
    );
  });
}
