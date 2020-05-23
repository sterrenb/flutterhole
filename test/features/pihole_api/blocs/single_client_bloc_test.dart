import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/pihole_api/blocs/single_client_bloc.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_client.dart';
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
  SingleClientBloc bloc;

  setUp(() {
    settings = PiholeSettings(title: 'First');
    mockApiRepository = MockApiRepository();
    mockSettingsRepository = MockSettingsRepository();
    bloc = SingleClientBloc(mockApiRepository, mockSettingsRepository);
  });

  tearDown(() {
    bloc.close();
  });

  blocTest(
    'Initially emits SingleClientStateInitial',
    build: () async => bloc,
    skip: 0,
    expect: [SingleClientStateInitial()],
  );

  blocTest(
    'Emits [] when nothing is added',
    build: () async => bloc,
    expect: [],
  );

  group('$SingleClientEventFetchQueries', () {
    final PiClient client = PiClient(name: 'test');
    final List<QueryData> queries = [QueryData(clientName: 'test')];
    final tFailure = Failure();

    blocTest(
      'Emits [$SingleClientStateLoading, $SingleClientStateSuccess] when $SingleClientEventFetchQueries succeeds',
      build: () async {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(settings));
        when(mockApiRepository.fetchQueriesForClient(settings, client))
            .thenAnswer((_) async => Right(queries));

        return bloc;
      },
      act: (SingleClientBloc bloc) async =>
          bloc.add(SingleClientEvent.fetchQueries(client)),
      expect: [
        SingleClientStateLoading(),
        SingleClientStateSuccess(client, queries),
      ],
    );

    blocTest(
      'Emits [$SingleClientStateLoading, $SingleClientStateFailure] when $SingleClientEventFetchQueries fails',
      build: () async {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Left(tFailure));

        return bloc;
      },
      act: (SingleClientBloc bloc) async =>
          bloc.add(SingleClientEvent.fetchQueries(client)),
      expect: [
        SingleClientStateLoading(),
        SingleClientStateFailure(tFailure),
      ],
    );
  });
}
