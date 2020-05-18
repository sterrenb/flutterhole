import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/pihole_api/blocs/query_log_bloc.dart';
import 'package:flutterhole/features/pihole_api/data/models/query_data.dart';
import 'package:flutterhole/features/pihole_api/data/repositories/api_repository.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/features/settings/data/repositories/settings_repository.dart';
import 'package:mockito/mockito.dart';

import '../../../test_dependency_injection.dart';

class MockApiRepository extends Mock implements ApiRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  setUpAllForTest();

  PiholeSettings settings;
  ApiRepository mockApiRepository;
  SettingsRepository mockSettingsRepository;
  QueryLogBloc bloc;

  setUp(() {
    settings = PiholeSettings(title: 'First', apiToken: 'token');
    mockApiRepository = MockApiRepository();
    mockSettingsRepository = MockSettingsRepository();
    bloc = QueryLogBloc(mockApiRepository, mockSettingsRepository);
  });

  tearDown(() {
    bloc.close();
  });

  blocTest(
    'Initially emits QueryLogStateInitial',
    build: () async => bloc,
    skip: 0,
    expect: [QueryLogStateInitial()],
  );

  blocTest(
    'Emits [] when nothing is added',
    build: () async => bloc,
    expect: [],
  );

  group('$QueryLogEventFetchAll', () {
    final List<QueryData> queries = [
      QueryData(clientName: 'first'),
      QueryData(clientName: 'second'),
      QueryData(clientName: 'last'),
    ];
    final tFailure = Failure();

    blocTest(
      'Emits [$QueryLogStateLoading, $QueryLogStateSuccess] when $QueryLogEventFetchAll succeeds',
      build: () async {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(settings));
        when(mockApiRepository.fetchManyQueryData(settings))
            .thenAnswer((_) async => Right(queries));

        return bloc;
      },
      act: (QueryLogBloc bloc) async => bloc.add(QueryLogEvent.fetchAll()),
      expect: [QueryLogStateLoading(), QueryLogStateSuccess(queries)],
    );

    blocTest(
      'Emits [$QueryLogStateLoading, $QueryLogStateFailure] when $QueryLogEventFetchAll fails',
      build: () async {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(settings));
        when(mockApiRepository.fetchManyQueryData(settings))
            .thenAnswer((_) async => Left(tFailure));

        return bloc;
      },
      act: (QueryLogBloc bloc) async => bloc.add(QueryLogEvent.fetchAll()),
      expect: [QueryLogStateLoading(), QueryLogStateFailure(tFailure)],
    );
  });

  group('$QueryLogEventFetchSome', () {
    final List<QueryData> queries = [
      QueryData(clientName: 'first'),
      QueryData(clientName: 'second'),
      QueryData(clientName: 'last'),
    ];
    final tFailure = Failure();
    final maxResults = 123;

    blocTest(
      'Emits [$QueryLogStateLoading, $QueryLogStateSuccess] when $QueryLogEventFetchSome succeeds',
      build: () async {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(settings));
        when(mockApiRepository.fetchManyQueryData(settings, maxResults))
            .thenAnswer((_) async => Right(queries));

        return bloc;
      },
      act: (QueryLogBloc bloc) async =>
          bloc.add(QueryLogEvent.fetchSome(maxResults)),
      expect: [QueryLogStateLoading(), QueryLogStateSuccess(queries)],
    );

    blocTest(
      'Emits [$QueryLogStateLoading, $QueryLogStateFailure] when $QueryLogEventFetchSome fails',
      build: () async {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(settings));
        when(mockApiRepository.fetchManyQueryData(settings, maxResults))
            .thenAnswer((_) async => Left(tFailure));

        return bloc;
      },
      act: (QueryLogBloc bloc) async =>
          bloc.add(QueryLogEvent.fetchSome(maxResults)),
      expect: [QueryLogStateLoading(), QueryLogStateFailure(tFailure)],
    );
  });
}
