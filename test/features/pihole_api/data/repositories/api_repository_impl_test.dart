import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/core/models/exceptions.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/pihole_api/data/datasources/api_data_source.dart';
import 'package:flutterhole/features/pihole_api/data/models/dns_query_type.dart';
import 'package:flutterhole/features/pihole_api/data/models/forward_destinations.dart';
import 'package:flutterhole/features/pihole_api/data/models/over_time_data.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_status.dart';
import 'package:flutterhole/features/pihole_api/data/models/summary.dart';
import 'package:flutterhole/features/pihole_api/data/models/toggle_status.dart';
import 'package:flutterhole/features/pihole_api/data/models/top_items.dart';
import 'package:flutterhole/features/pihole_api/data/models/top_sources.dart';
import 'package:flutterhole/features/pihole_api/data/repositories/api_repository_impl.dart';
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
      'should return $SummaryModel on successful fetchSummary',
      () async {
        // arrange
        final tSummary = SummaryModel(dnsQueriesToday: 5);
        when(mockApiDataSource.fetchSummary(piholeSettings))
            .thenAnswer((_) async => tSummary);
        // act
        final Either<Failure, SummaryModel> result =
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
        final Either<Failure, SummaryModel> result =
            await apiRepository.fetchSummary(piholeSettings);
        // assert
        expect(result, equals(Left(Failure('fetchSummary failed', tError))));
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
        when(mockApiDataSource.sleepPihole(piholeSettings, duration))
            .thenAnswer((_) async => toggleStatus);
        // act
        final Either<Failure, ToggleStatus> result =
            await apiRepository.sleepPihole(piholeSettings, duration);
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
        when(mockApiDataSource.sleepPihole(piholeSettings, duration))
            .thenThrow(tError);
        // act
        final Either<Failure, ToggleStatus> result =
            await apiRepository.sleepPihole(piholeSettings, duration);
        // assert
        expect(result, equals(Left(Failure('sleepPihole failed', tError))));
      },
    );
  });

  group('fetchQueriesOverTime', () {
    test(
      'should return $OverTimeData on successful fetchQueriesOverTime',
      () async {
        // arrange
        final overTimeData = OverTimeData(domainsOverTime: {}, adsOverTime: {});
        when(mockApiDataSource.fetchQueriesOverTime(piholeSettings))
            .thenAnswer((_) async => overTimeData);
        // act
        final Either<Failure, OverTimeData> result =
            await apiRepository.fetchQueriesOverTime(piholeSettings);
        // assert
        expect(result, equals(Right(overTimeData)));
      },
    );

    test(
      'should return $Failure on failed fetchQueriesOverTime',
      () async {
        // arrange
        final tError = PiException.emptyResponse();
        when(mockApiDataSource.fetchQueriesOverTime(piholeSettings))
            .thenThrow(tError);
        // act
        final Either<Failure, OverTimeData> result =
            await apiRepository.fetchQueriesOverTime(piholeSettings);
        // assert
        expect(result,
            equals(Left(Failure('fetchQueriesOverTime failed', tError))));
      },
    );
  });

  group('fetchTopSources', () {
    test(
      'should return $TopSourcesResult on successful fetchTopSources',
      () async {
        // arrange
        final topSources = TopSourcesResult(topSources: {});
        when(mockApiDataSource.fetchTopSources(piholeSettings))
            .thenAnswer((_) async => topSources);
        // act
        final Either<Failure, TopSourcesResult> result =
            await apiRepository.fetchTopSources(piholeSettings);
        // assert
        expect(result, equals(Right(topSources)));
      },
    );

    test(
      'should return $Failure on failed fetchTopSources',
      () async {
        // arrange
        final tError = PiException.emptyResponse();
        when(mockApiDataSource.fetchTopSources(piholeSettings))
            .thenThrow(tError);
        // act
        final Either<Failure, TopSourcesResult> result =
            await apiRepository.fetchTopSources(piholeSettings);
        // assert
        expect(result, equals(Left(Failure('fetchTopSources failed', tError))));
      },
    );
  });

  group('fetchTopItems', () {
    test(
      'should return $TopItems on successful fetchTopItems',
      () async {
        // arrange
        final topItems = TopItems(
          topQueries: {},
          topAds: {},
        );
        when(mockApiDataSource.fetchTopItems(piholeSettings))
            .thenAnswer((_) async => topItems);
        // act
        final Either<Failure, TopItems> result =
            await apiRepository.fetchTopItems(piholeSettings);
        // assert
        expect(result, equals(Right(topItems)));
      },
    );

    test(
      'should return $Failure on failed fetchTopItems',
      () async {
        // arrange
        final tError = PiException.emptyResponse();
        when(mockApiDataSource.fetchTopItems(piholeSettings)).thenThrow(tError);
        // act
        final Either<Failure, TopItems> result =
            await apiRepository.fetchTopItems(piholeSettings);
        // assert
        expect(result, equals(Left(Failure('fetchTopItems failed', tError))));
      },
    );
  });

  group('fetchForwardDestinations', () {
    test(
      'should return $ForwardDestinationsResult on successful fetchForwardDestinations',
      () async {
        // arrange
        final forwardDestinations =
            ForwardDestinationsResult(forwardDestinations: {});
        when(mockApiDataSource.fetchForwardDestinations(piholeSettings))
            .thenAnswer((_) async => forwardDestinations);
        // act
        final Either<Failure, ForwardDestinationsResult> result =
            await apiRepository.fetchForwardDestinations(piholeSettings);
        // assert
        expect(result, equals(Right(forwardDestinations)));
      },
    );

    test(
      'should return $Failure on failed fetchForwardDestinations',
      () async {
        // arrange
        final tError = PiException.emptyResponse();
        when(mockApiDataSource.fetchForwardDestinations(piholeSettings))
            .thenThrow(tError);
        // act
        final Either<Failure, ForwardDestinationsResult> result =
            await apiRepository.fetchForwardDestinations(piholeSettings);
        // assert
        expect(result,
            equals(Left(Failure('fetchForwardDestinations failed', tError))));
      },
    );
  });

  group('fetchQueryTypes', () {
    test(
      'should return $DnsQueryTypeResult on successful fetchQueryTypes',
      () async {
        // arrange
        final queryTypes = DnsQueryTypeResult();
        when(mockApiDataSource.fetchQueryTypes(piholeSettings))
            .thenAnswer((_) async => queryTypes);
        // act
        final Either<Failure, DnsQueryTypeResult> result =
            await apiRepository.fetchQueryTypes(piholeSettings);
        // assert
        expect(result, equals(Right(queryTypes)));
      },
    );

    test(
      'should return $Failure on failed fetchQueryTypes',
      () async {
        // arrange
        final tError = PiException.emptyResponse();
        when(mockApiDataSource.fetchQueryTypes(piholeSettings))
            .thenThrow(tError);
        // act
        final Either<Failure, DnsQueryTypeResult> result =
            await apiRepository.fetchQueryTypes(piholeSettings);
        // assert
        expect(result, equals(Left(Failure('fetchQueryTypes failed', tError))));
      },
    );
  });
}
