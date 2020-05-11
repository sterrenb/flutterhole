import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/pihole_api/blocs/connection_bloc.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_status.dart';
import 'package:flutterhole/features/pihole_api/data/models/toggle_status.dart';
import 'package:flutterhole/features/pihole_api/data/repositories/connection_repository.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/features/settings/data/repositories/settings_repository.dart';
import 'package:mockito/mockito.dart';

import '../../../test_dependency_injection.dart';

class MockConnectionRepository extends Mock implements ConnectionRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  setUpAllForTest();

  PiholeSettings settings;
  ConnectionRepository mockConnectionRepository;
  SettingsRepository mockSettingsRepository;
  ConnectionBloc bloc;

  setUp(() {
    settings = PiholeSettings(title: 'First');
    mockConnectionRepository = MockConnectionRepository();
    mockSettingsRepository = MockSettingsRepository();
    bloc = ConnectionBloc(mockConnectionRepository, mockSettingsRepository);
  });

  tearDown(() {
    bloc.close();
  });

  blocTest(
    'Initially emits ConnectionState.initial',
    build: () async => bloc,
    skip: 0,
    expect: [ConnectionState.initial()],
  );

  blocTest(
    'Emits [] when nothing is added',
    build: () async => bloc,
    expect: [],
  );

  group('$ConnectionEvent.ping()', () {
    final ToggleStatus toggleStatus = ToggleStatus(PiStatusEnum.enabled);
    final failure = Failure('test');

    blocTest(
      'Emits [$ConnectionState.loading(), $ConnectionState.active(toggleStatus)] when $ConnectionEvent.ping() succeeds',
      build: () async {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(settings));
        when(mockConnectionRepository.pingPihole(settings))
            .thenAnswer((_) async => Right(toggleStatus));

        return bloc;
      },
      act: (ConnectionBloc bloc) async => bloc.add(ConnectionEvent.ping()),
      expect: [ConnectionState.loading(), ConnectionState.active(toggleStatus)],
    );

    blocTest(
      'Emits [$ConnectionState.loading(), $ConnectionState.failure] when fetchActivePiholeSettings fails',
      build: () async {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Left(failure));
        when(mockConnectionRepository.pingPihole(settings))
            .thenAnswer((_) async => Right(toggleStatus));

        return bloc;
      },
      act: (ConnectionBloc bloc) async => bloc.add(ConnectionEvent.ping()),
      expect: [ConnectionState.loading(), ConnectionState.failure(failure)],
    );

    blocTest(
      'Emits [$ConnectionState.loading(), $ConnectionState.failure] when pingPihole fails',
      build: () async {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(settings));
        when(mockConnectionRepository.pingPihole(settings))
            .thenAnswer((_) async => Left(failure));

        return bloc;
      },
      act: (ConnectionBloc bloc) async => bloc.add(ConnectionEvent.ping()),
      expect: [ConnectionState.loading(), ConnectionState.failure(failure)],
    );
  });
}
