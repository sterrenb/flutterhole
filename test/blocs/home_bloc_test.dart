import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/home/blocs/home_bloc.dart';
import 'package:flutterhole/features/pihole_api/data/models/dns_query_type.dart';
import 'package:flutterhole/features/pihole_api/data/models/forward_destinations.dart';
import 'package:flutterhole/features/pihole_api/data/models/over_time_data.dart';
import 'package:flutterhole/features/pihole_api/data/models/summary.dart';
import 'package:flutterhole/features/pihole_api/data/models/top_items.dart';
import 'package:flutterhole/features/pihole_api/data/models/top_sources.dart';
import 'package:flutterhole/features/pihole_api/data/repositories/api_repository.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/features/settings/data/repositories/settings_repository.dart';
import 'package:mockito/mockito.dart';

import '../test_dependency_injection.dart';

class MockApiRepository extends Mock implements ApiRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  setUpAllForTest();

  ApiRepository mockApiRepository;
  SettingsRepository mockSettingsRepository;
  HomeBloc bloc;

  setUp(() {
    mockApiRepository = MockApiRepository();
    mockSettingsRepository = MockSettingsRepository();
    bloc = HomeBloc(mockApiRepository, mockSettingsRepository);
  });

  tearDown(() {
    bloc.close();
  });

  blocTest(
    'Initially emits $HomeStateInitial',
    build: () async => bloc,
    skip: 0,
    expect: [HomeStateInitial()],
  );

  blocTest(
    'Emits [] when nothing is added',
    build: () async => bloc,
    expect: [],
  );

  group('$HomeEventFetch', () {
    final piholeSettings = PiholeSettings(baseUrl: 'http://example.com');
    final SummaryModel tSummary = SummaryModel(domainsBeingBlocked: 123);
    final OverTimeData tOverTimeData =
        OverTimeData(domainsOverTime: {}, adsOverTime: {});
    final TopSourcesResult tTopSources = TopSourcesResult(topSources: {});
    final TopItems tTopItems = TopItems(topQueries: {
      'a': 5,
    }, topAds: {
      'b': 10
    });
    final ForwardDestinationsResult tForwardDestinations =
        ForwardDestinationsResult(forwardDestinations: {});
    final DnsQueryTypeResult tDnsQueryTypeResult =
        DnsQueryTypeResult(dnsQueryTypes: []);

    blocTest(
      'Emits [$HomeStateLoading, $HomeStateSuccess] when $HomeEventFetch succeeds',
      build: () async {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(piholeSettings));
        when(mockApiRepository.fetchSummary(any))
            .thenAnswer((_) async => Right(tSummary));
        when(mockApiRepository.fetchQueriesOverTime(any))
            .thenAnswer((_) async => Right(tOverTimeData));
        when(mockApiRepository.fetchTopSources(any))
            .thenAnswer((_) async => Right(tTopSources));
        when(mockApiRepository.fetchTopItems(any))
            .thenAnswer((_) async => Right(tTopItems));
        when(mockApiRepository.fetchForwardDestinations(any))
            .thenAnswer((_) async => Right(tForwardDestinations));
        when(mockApiRepository.fetchQueryTypes(any))
            .thenAnswer((_) async => Right(tDnsQueryTypeResult));

        return bloc;
      },
      act: (HomeBloc bloc) async => bloc.add(HomeEventFetch()),
      expect: [
        HomeStateLoading(),
        HomeStateSuccess(
          Right(tSummary),
          Right(tOverTimeData),
          Right(tTopSources),
          Right(tTopItems),
          Right(tForwardDestinations),
          Right(tDnsQueryTypeResult),
        )
      ],
    );

    blocTest(
      'Emits [$HomeStateLoading, $HomeStateSuccess] when $HomeEventFetch partially succeeds',
      build: () async {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(piholeSettings));
        when(mockApiRepository.fetchSummary(any))
            .thenAnswer((_) async => Right(tSummary));
        when(mockApiRepository.fetchQueriesOverTime(any))
            .thenAnswer((_) async => Right(tOverTimeData));
        when(mockApiRepository.fetchTopSources(any))
            .thenAnswer((_) async => Left(Failure()));
        when(mockApiRepository.fetchTopItems(any))
            .thenAnswer((_) async => Left(Failure()));
        when(mockApiRepository.fetchForwardDestinations(any))
            .thenAnswer((_) async => Left(Failure()));
        when(mockApiRepository.fetchQueryTypes(any))
            .thenAnswer((_) async => Left(Failure()));

        return bloc;
      },
      act: (HomeBloc bloc) async => bloc.add(HomeEventFetch()),
      expect: [
        HomeStateLoading(),
        HomeStateSuccess(
          Right(tSummary),
          Right(tOverTimeData),
          Left(Failure()),
          Left(Failure()),
          Left(Failure()),
          Left(Failure()),
        )
      ],
    );

    final tFailure0 = Failure('test #0');
    final tFailure1 = Failure('test #1');
    final tFailure2 = Failure('test #2');
    final tFailure3 = Failure('test #3');
    final tFailure4 = Failure('test #4');
    final tFailure5 = Failure('test #5');

    blocTest(
      'Emits [$HomeStateLoading, $HomeStateFailure] when $HomeEventFetch fails',
      build: () async {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(piholeSettings));
        when(mockApiRepository.fetchSummary(any))
            .thenAnswer((_) async => Left(tFailure0));
        when(mockApiRepository.fetchQueriesOverTime(any))
            .thenAnswer((_) async => Left(tFailure1));
        when(mockApiRepository.fetchTopSources(any))
            .thenAnswer((_) async => Left(tFailure2));
        when(mockApiRepository.fetchTopItems(any))
            .thenAnswer((_) async => Left(tFailure3));
        when(mockApiRepository.fetchForwardDestinations(any))
            .thenAnswer((_) async => Left(tFailure4));
        when(mockApiRepository.fetchQueryTypes(any))
            .thenAnswer((_) async => Left(tFailure5));

        return bloc;
      },
      act: (HomeBloc bloc) async => bloc.add(HomeEventFetch()),
      expect: [
        HomeStateLoading(),
        HomeStateFailure(Failure('all requests failed', [
          tFailure0,
          tFailure1,
          tFailure2,
          tFailure3,
          tFailure4,
          tFailure5,
        ])),
      ],
    );

    blocTest(
      'Emits [$HomeStateLoading, $HomeStateFailure] when no active settings are available',
      build: () async {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Left(Failure()));

        return bloc;
      },
      act: (HomeBloc bloc) async => bloc.add(HomeEventFetch()),
      expect: [
        HomeStateLoading(),
        HomeStateFailure(Failure()),
      ],
    );
  });
}
