import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/core/models/exceptions.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/pihole_api/data/datasources/api_data_source.dart';
import 'package:flutterhole/features/pihole_api/data/models/blacklist.dart';
import 'package:flutterhole/features/pihole_api/data/models/blacklist_item.dart';
import 'package:flutterhole/features/pihole_api/data/models/dns_query_type.dart';
import 'package:flutterhole/features/pihole_api/data/models/forward_destinations.dart';
import 'package:flutterhole/features/pihole_api/data/models/list_response.dart';
import 'package:flutterhole/features/pihole_api/data/models/many_query_data.dart';
import 'package:flutterhole/features/pihole_api/data/models/over_time_data.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_client.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_extras.dart';
import 'package:flutterhole/features/pihole_api/data/models/query_data.dart';
import 'package:flutterhole/features/pihole_api/data/models/summary.dart';
import 'package:flutterhole/features/pihole_api/data/models/top_items.dart';
import 'package:flutterhole/features/pihole_api/data/models/top_sources.dart';
import 'package:flutterhole/features/pihole_api/data/models/whitelist.dart';
import 'package:flutterhole/features/pihole_api/data/models/whitelist_item.dart';
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

  final tError = PiException.emptyResponse(TypeError());

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

        when(mockApiDataSource.fetchSummary(piholeSettings)).thenThrow(tError);
        // act
        final Either<Failure, SummaryModel> result =
            await apiRepository.fetchSummary(piholeSettings);
        // assert
        expect(result, equals(Left(Failure('fetchSummary failed', tError))));
      },
    );
  });

  group('fetchExtras', () {
    test(
      'should return $PiExtras on successful fetchExtras',
      () async {
        // arrange
        final tExtras = PiExtras(
          temperature: 12.23,
          load: [
            1,
            2,
            3,
          ],
          memoryUsage: 45.67,
        );
        when(mockApiDataSource.fetchExtras(piholeSettings))
            .thenAnswer((_) async => tExtras);
        // act
        final Either<Failure, PiExtras> result =
            await apiRepository.fetchExtras(piholeSettings);
        // assert
        expect(result, equals(Right(tExtras)));
      },
    );

    test(
      'should return $Failure on failed fetchExtras',
      () async {
        // arrange

        when(mockApiDataSource.fetchExtras(piholeSettings)).thenThrow(tError);
        // act
        final Either<Failure, PiExtras> result =
            await apiRepository.fetchExtras(piholeSettings);
        // assert
        expect(result, equals(Left(Failure('fetchExtras failed', tError))));
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

  group('fetchQueryDataForClient', () {
    final PiClient client = PiClient(name: 'test.org');

    test(
      'should return reversed List<QueryData> on successful fetchQueriesForClient',
      () async {
        // arrange
        final ManyQueryData manyQueryData = ManyQueryData(
          data: [
            QueryData(clientName: 'first'),
            QueryData(clientName: 'second'),
            QueryData(clientName: 'third'),
          ],
        );

        when(mockApiDataSource.fetchQueryDataForClient(piholeSettings, client))
            .thenAnswer((_) async => manyQueryData);
        // act
        final Either<Failure, List<QueryData>> result =
            await apiRepository.fetchQueriesForClient(piholeSettings, client);
        // assert
        result.fold(
          (failure) => fail('result should be Right'),
          (list) {
            expect(list, equals(manyQueryData.data.reversed.toList()));
          },
        );
      },
    );

    test(
      'should return $Failure on failed fetchQueriesForClient',
      () async {
        // arrange

        when(mockApiDataSource.fetchQueryDataForClient(piholeSettings, client))
            .thenThrow(tError);
        // act
        final Either<Failure, List<QueryData>> result =
            await apiRepository.fetchQueriesForClient(piholeSettings, client);
        // assert
        expect(result,
            equals(Left(Failure('fetchQueriesForClient failed', tError))));
      },
    );
  });

  group('fetchQueriesForDomain', () {
    final String domain = 'test.org';
    test(
      'should return reversed List<QueryData> on successful fetchQueriesForDomain',
      () async {
        // arrange
        final ManyQueryData manyQueryData = ManyQueryData(
          data: [QueryData(domain: domain)],
        );
        when(mockApiDataSource.fetchQueryDataForDomain(piholeSettings, domain))
            .thenAnswer((_) async => manyQueryData);
        // act
        final Either<Failure, List<QueryData>> result =
            await apiRepository.fetchQueriesForDomain(piholeSettings, domain);
        // assert
        result.fold(
          (failure) => fail('result should be Right'),
          (list) {
            expect(list, equals(manyQueryData.data.reversed.toList()));
          },
        );
      },
    );

    test(
      'should return $Failure on failed fetchQueriesForDomain',
      () async {
        // arrange

        when(mockApiDataSource.fetchQueryDataForDomain(piholeSettings, domain))
            .thenThrow(tError);
        // act
        final Either<Failure, List<QueryData>> result =
            await apiRepository.fetchQueriesForDomain(piholeSettings, domain);
        // assert
        expect(result,
            equals(Left(Failure('fetchQueriesForDomain failed', tError))));
      },
    );
  });

  group('fetchManyQueryData', () {
    test(
      'should return reversed List<QueryData> on successful fetchManyQueryData without maxResults',
      () async {
        // arrange
        final ManyQueryData manyQueryData = ManyQueryData(
          data: [
            QueryData(clientName: 'first'),
            QueryData(clientName: 'second'),
            QueryData(clientName: 'third'),
          ],
        );
        when(mockApiDataSource.fetchManyQueryData(piholeSettings))
            .thenAnswer((_) async => manyQueryData);
        // act
        final Either<Failure, List<QueryData>> result =
            await apiRepository.fetchManyQueryData(piholeSettings);
        // assert
        result.fold(
          (failure) => fail('result should be Right'),
          (list) {
            expect(list, equals(manyQueryData.data.reversed.toList()));
          },
        );
      },
    );

    test(
      'should return reversed List<QueryData> on successful fetchManyQueryData with maxResults',
      () async {
        // arrange
        final int maxResults = 123;
        final ManyQueryData manyQueryData = ManyQueryData(
          data: [
            QueryData(clientName: 'first'),
            QueryData(clientName: 'second'),
            QueryData(clientName: 'third'),
          ],
        );
        when(mockApiDataSource.fetchManyQueryData(piholeSettings, maxResults))
            .thenAnswer((_) async => manyQueryData);
        // act
        final Either<Failure, List<QueryData>> result =
            await apiRepository.fetchManyQueryData(piholeSettings, maxResults);
        // assert
        result.fold(
          (failure) => fail('result should be Right'),
          (list) {
            expect(list, equals(manyQueryData.data.reversed.toList()));
          },
        );
      },
    );

    test(
      'should return $Failure on failed fetchManyQueryData',
      () async {
        // arrange

        when(mockApiDataSource.fetchManyQueryData(piholeSettings))
            .thenThrow(tError);
        // act
        final Either<Failure, List<QueryData>> result =
            await apiRepository.fetchManyQueryData(piholeSettings);
        // assert
        expect(
            result, equals(Left(Failure('fetchManyQueryData failed', tError))));
      },
    );
  });

  group('fetchWhitelist', () {
    test(
      'should return $Whitelist on successful fetchWhitelist',
      () async {
        // arrange
        final whitelist =
            Whitelist(data: [WhitelistItem(id: 2, comment: 'hi')]);
        when(mockApiDataSource.fetchWhitelist(piholeSettings))
            .thenAnswer((_) async => whitelist);
        when(mockApiDataSource.fetchRegexWhitelist(piholeSettings))
            .thenAnswer((_) async => whitelist);
        // act
        final Either<Failure, Whitelist> result =
            await apiRepository.fetchWhitelist(piholeSettings);
        // assert
        expect(
            result,
            equals(Right(Whitelist(data: [
              ...whitelist.data,
              ...whitelist.data,
            ]))));
      },
    );

    test(
      'should return $Failure on failed fetchWhitelist',
      () async {
        // arrange

        when(mockApiDataSource.fetchWhitelist(piholeSettings))
            .thenThrow(tError);
        // act
        final Either<Failure, Whitelist> result =
            await apiRepository.fetchWhitelist(piholeSettings);
        // assert
        expect(result, equals(Left(Failure('fetchWhitelist failed', tError))));
      },
    );
  });

  group('fetchBlacklist', () {
    test(
      'should return $Blacklist on successful fetchBlacklist',
      () async {
        // arrange
        final blacklist =
            Blacklist(data: [BlacklistItem(id: 2, comment: 'hi')]);
        when(mockApiDataSource.fetchBlacklist(piholeSettings))
            .thenAnswer((_) async => blacklist);
        when(mockApiDataSource.fetchRegexBlacklist(piholeSettings))
            .thenAnswer((_) async => blacklist);
        // act
        final Either<Failure, Blacklist> result =
            await apiRepository.fetchBlacklist(piholeSettings);
        // assert
        expect(
            result,
            equals(Right(Blacklist(data: [
              ...blacklist.data,
              ...blacklist.data,
            ]))));
      },
    );

    test(
      'should return $Failure on failed fetchBlacklist',
      () async {
        // arrange

        when(mockApiDataSource.fetchBlacklist(piholeSettings))
            .thenThrow(tError);
        // act
        final Either<Failure, Blacklist> result =
            await apiRepository.fetchBlacklist(piholeSettings);
        // assert
        expect(
            result,
            equals(Left<Failure, Blacklist>(
                Failure('fetchBlacklist failed', tError))));
      },
    );
  });

  group('addToWhitelist', () {
    test(
      'should return $ListResponse on successful addToWhitelist',
      () async {
        // arrange
        final ListResponse response = ListResponse(success: true);
        final String domain = 'domain';
        when(mockApiDataSource.addToWhitelist(piholeSettings, domain, false))
            .thenAnswer((_) async => response);
        // act
        final Either<Failure, ListResponse> result =
            await apiRepository.addToWhitelist(piholeSettings, domain, false);
        // assert
        expect(result, equals(Right<Failure, ListResponse>(response)));
      },
    );

    test(
      'should return $Failure on failed addToWhitelist',
      () async {
        // arrange
        final String domain = 'domain';
        when(mockApiDataSource.addToWhitelist(piholeSettings, domain, false))
            .thenThrow(tError);
        // act
        final Either<Failure, ListResponse> result =
            await apiRepository.addToWhitelist(piholeSettings, domain, false);
        // assert
        expect(
            result,
            equals(Left<Failure, ListResponse>(
                Failure('addToWhitelist failed', tError))));
      },
    );
  });

  group('addToBlacklist', () {
    test(
      'should return $ListResponse on successful addToBlacklist',
      () async {
        // arrange
        final ListResponse response = ListResponse(success: true);
        final String domain = 'domain';
        when(mockApiDataSource.addToBlacklist(piholeSettings, domain, false))
            .thenAnswer((_) async => response);
        // act
        final Either<Failure, ListResponse> result =
            await apiRepository.addToBlacklist(piholeSettings, domain, false);
        // assert
        expect(result, equals(Right<Failure, ListResponse>(response)));
      },
    );

    test(
      'should return $Failure on failed addToBlacklist',
      () async {
        // arrange
        final String domain = 'domain';
        when(mockApiDataSource.addToBlacklist(piholeSettings, domain, false))
            .thenThrow(tError);
        // act
        final Either<Failure, ListResponse> result =
            await apiRepository.addToBlacklist(piholeSettings, domain, false);
        // assert
        expect(
            result,
            equals(Left<Failure, ListResponse>(
                Failure('addToBlacklist failed', tError))));
      },
    );
  });

  group('removeFromWhitelist', () {
    test(
      'should return $ListResponse on successful removeFromWhitelist',
      () async {
        // arrange
        final ListResponse response = ListResponse(success: true);
        final String domain = 'domain';
        when(mockApiDataSource.removeFromWhitelist(
                piholeSettings, domain, false))
            .thenAnswer((_) async => response);
        // act
        final Either<Failure, ListResponse> result = await apiRepository
            .removeFromWhitelist(piholeSettings, domain, false);
        // assert
        expect(result, equals(Right<Failure, ListResponse>(response)));
      },
    );

    test(
      'should return $Failure on failed removeFromWhitelist',
      () async {
        // arrange
        final String domain = 'domain';
        when(mockApiDataSource.removeFromWhitelist(
                piholeSettings, domain, false))
            .thenThrow(tError);
        // act
        final Either<Failure, ListResponse> result = await apiRepository
            .removeFromWhitelist(piholeSettings, domain, false);
        // assert
        expect(
            result,
            equals(Left<Failure, ListResponse>(
                Failure('removeFromWhitelist failed', tError))));
      },
    );
  });

  group('removeFromBlacklist', () {
    test(
      'should return $ListResponse on successful removeFromBlacklist',
      () async {
        // arrange
        final ListResponse response = ListResponse(success: true);
        final String domain = 'domain';
        when(mockApiDataSource.removeFromBlacklist(
                piholeSettings, domain, false))
            .thenAnswer((_) async => response);
        // act
        final Either<Failure, ListResponse> result = await apiRepository
            .removeFromBlacklist(piholeSettings, domain, false);
        // assert
        expect(result, equals(Right<Failure, ListResponse>(response)));
      },
    );

    test(
      'should return $Failure on failed removeFromBlacklist',
      () async {
        // arrange
        final String domain = 'domain';
        when(mockApiDataSource.removeFromBlacklist(
                piholeSettings, domain, false))
            .thenThrow(tError);
        // act
        final Either<Failure, ListResponse> result = await apiRepository
            .removeFromBlacklist(piholeSettings, domain, false);
        // assert
        expect(
            result,
            equals(Left<Failure, ListResponse>(
                Failure('removeFromBlacklist failed', tError))));
      },
    );
  });
}
