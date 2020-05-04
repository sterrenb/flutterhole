import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/core/models/exceptions.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/api/data/datasources/api_data_source.dart';
import 'package:flutterhole/features/api/data/models/pi_status.dart';
import 'package:flutterhole/features/api/data/models/summary.dart';
import 'package:flutterhole/features/api/data/models/toggle_status.dart';
import 'package:flutterhole/features/api/data/repositories/api_repository_impl.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:mockito/mockito.dart';

import '../../../../test_dependency_injection.dart';

class MockApiDataSource extends Mock implements ApiDataSource {}

void main() async {
  await setUpAllForTest();

  ApiRepositoryImpl apiRepository;
  ApiDataSource mockApiDataSource;
  PiholeSettings piholeSettings;

  setUp(() {
    piholeSettings = PiholeSettings(baseUrl: 'http://example.com');
    mockApiDataSource = MockApiDataSource();
    apiRepository = ApiRepositoryImpl(mockApiDataSource);
  });

  group('fetchSummary', () {
    test(
      'should return $Summary on successful fetchSummary',
      () async {
        // arrange
        final tSummary = Summary(dnsQueriesToday: 5);
        when(mockApiDataSource.fetchSummary(piholeSettings))
            .thenAnswer((_) async => tSummary);
        // act
        final Either<Failure, Summary> result =
            await apiRepository.fetchSummary(piholeSettings);
        // assert
        expect(result, equals(Right(tSummary)));
      },
    );

    test(
      'should return $Failure on failed fetchSummary',
      () async {
        // arrange
        final tError = PiException.emptyResponse();
        when(mockApiDataSource.fetchSummary(piholeSettings)).thenThrow(tError);
        // act
        final Either<Failure, Summary> result =
            await apiRepository.fetchSummary(piholeSettings);
        // assert
        expect(result, equals(Left(Failure())));
      },
    );
  });

  group('pingPihole', () {
    test(
      'should return $ToggleStatus on successful pingPihole',
      () async {
        // arrange
        final toggleStatus = ToggleStatus(status: PiStatusEnum.enabled);
        when(mockApiDataSource.pingPihole(piholeSettings))
            .thenAnswer((_) async => toggleStatus);
        // act
        final Either<Failure, ToggleStatus> result =
            await apiRepository.pingPihole(piholeSettings);
        // assert
        expect(result, equals(Right(toggleStatus)));
      },
    );

    test(
      'should return $Failure on failed pingPihole',
      () async {
        // arrange
        final tError = PiException.emptyResponse();
        when(mockApiDataSource.pingPihole(piholeSettings)).thenThrow(tError);
        // act
        final Either<Failure, ToggleStatus> result =
            await apiRepository.pingPihole(piholeSettings);
        // assert
        expect(result, equals(Left(Failure())));
      },
    );
  });

  group('enablePihole', () {
    test(
      'should return $ToggleStatus on successful enablePihole',
      () async {
        // arrange
        final toggleStatus = ToggleStatus(status: PiStatusEnum.enabled);
        when(mockApiDataSource.enablePihole(piholeSettings))
            .thenAnswer((_) async => toggleStatus);
        // act
        final Either<Failure, ToggleStatus> result =
            await apiRepository.enablePihole(piholeSettings);
        // assert
        expect(result, equals(Right(toggleStatus)));
      },
    );

    test(
      'should return $Failure on failed enablePihole',
      () async {
        // arrange
        final tError = PiException.emptyResponse();
        when(mockApiDataSource.enablePihole(piholeSettings)).thenThrow(tError);
        // act
        final Either<Failure, ToggleStatus> result =
            await apiRepository.enablePihole(piholeSettings);
        // assert
        expect(result, equals(Left(Failure())));
      },
    );
  });

  group('disablePihole', () {
    test(
      'should return $ToggleStatus on successful disablePihole',
      () async {
        // arrange
        final toggleStatus = ToggleStatus(status: PiStatusEnum.enabled);
        when(mockApiDataSource.disablePihole(piholeSettings))
            .thenAnswer((_) async => toggleStatus);
        // act
        final Either<Failure, ToggleStatus> result =
            await apiRepository.disablePihole(piholeSettings);
        // assert
        expect(result, equals(Right(toggleStatus)));
      },
    );

    test(
      'should return $Failure on failed disablePihole',
      () async {
        // arrange
        final tError = PiException.emptyResponse();
        when(mockApiDataSource.disablePihole(piholeSettings)).thenThrow(tError);
        // act
        final Either<Failure, ToggleStatus> result =
            await apiRepository.disablePihole(piholeSettings);
        // assert
        expect(result, equals(Left(Failure())));
      },
    );
  });
}
