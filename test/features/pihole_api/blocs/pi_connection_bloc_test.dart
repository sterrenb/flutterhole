import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/pihole_api/blocs/pi_connection_bloc.dart';
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
  PiConnectionBloc bloc;

  setUp(() {
    settings = PiholeSettings(title: 'First');
    mockConnectionRepository = MockConnectionRepository();
    mockSettingsRepository = MockSettingsRepository();
    bloc = PiConnectionBloc(mockConnectionRepository, mockSettingsRepository);
  });

  tearDown(() {
    bloc.close();
  });

  blocTest(
    'Initially emits PiConnectionState.initial',
    build: () async => bloc,
    skip: 0,
    expect: [PiConnectionState.initial()],
  );

  blocTest(
    'Emits [] when nothing is added',
    build: () async => bloc,
    expect: [],
  );

  group('$PiConnectionEvent.ping()', () {
    final ToggleStatus toggleStatus = ToggleStatus(PiStatusEnum.enabled);
    final failure = Failure('test');

    blocTest(
      'Emits [$PiConnectionState.loading(), $PiConnectionState.active(toggleStatus)] when $PiConnectionEvent.ping() succeeds',
      build: () async {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(settings));
        when(mockConnectionRepository.pingPihole(settings))
            .thenAnswer((_) async => Right(toggleStatus));

        return bloc;
      },
      act: (PiConnectionBloc bloc) async => bloc.add(PiConnectionEvent.ping()),
      expect: [PiConnectionState.loading(), PiConnectionState.active(toggleStatus)],
    );

    blocTest(
      'Emits [$PiConnectionState.loading(), $PiConnectionState.failure] when fetchActivePiholeSettings fails',
      build: () async {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Left(failure));

        return bloc;
      },
      act: (PiConnectionBloc bloc) async => bloc.add(PiConnectionEvent.ping()),
      expect: [PiConnectionState.loading(), PiConnectionState.failure(failure)],
    );

    blocTest(
      'Emits [$PiConnectionState.loading(), $PiConnectionState.failure] when pingPihole fails',
      build: () async {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(settings));
        when(mockConnectionRepository.pingPihole(settings))
            .thenAnswer((_) async => Left(failure));

        return bloc;
      },
      act: (PiConnectionBloc bloc) async => bloc.add(PiConnectionEvent.ping()),
      expect: [PiConnectionState.loading(), PiConnectionState.failure(failure)],
    );
  });

  group('$PiConnectionEvent.enable()', () {
    final ToggleStatus toggleStatus = ToggleStatus(PiStatusEnum.enabled);
    final failure = Failure('test');

    blocTest(
      'Emits [$PiConnectionState.loading(), $PiConnectionState.active(toggleStatus)] when $PiConnectionEvent.enable() succeeds',
      build: () async {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(settings));
        when(mockConnectionRepository.enablePihole(settings))
            .thenAnswer((_) async => Right(toggleStatus));

        return bloc;
      },
      act: (PiConnectionBloc bloc) async => bloc.add(PiConnectionEvent.enable()),
      expect: [PiConnectionState.loading(), PiConnectionState.active(toggleStatus)],
    );

    blocTest(
      'Emits [$PiConnectionState.loading(), $PiConnectionState.failure] when fetchActivePiholeSettings fails',
      build: () async {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Left(failure));

        return bloc;
      },
      act: (PiConnectionBloc bloc) async => bloc.add(PiConnectionEvent.enable()),
      expect: [PiConnectionState.loading(), PiConnectionState.failure(failure)],
    );

    blocTest(
      'Emits [$PiConnectionState.loading(), $PiConnectionState.failure] when enablePihole fails',
      build: () async {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(settings));
        when(mockConnectionRepository.enablePihole(settings))
            .thenAnswer((_) async => Left(failure));

        return bloc;
      },
      act: (PiConnectionBloc bloc) async => bloc.add(PiConnectionEvent.enable()),
      expect: [PiConnectionState.loading(), PiConnectionState.failure(failure)],
    );
  });

  group('$PiConnectionEvent.disable()', () {
    final ToggleStatus toggleStatus = ToggleStatus(PiStatusEnum.disabled);
    final failure = Failure('test');

    blocTest(
      'Emits [$PiConnectionState.loading(), $PiConnectionState.active(toggleStatus)] when $PiConnectionEvent.disable() succeeds',
      build: () async {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(settings));
        when(mockConnectionRepository.disablePihole(settings))
            .thenAnswer((_) async => Right(toggleStatus));

        return bloc;
      },
      act: (PiConnectionBloc bloc) async => bloc.add(PiConnectionEvent.disable()),
      expect: [PiConnectionState.loading(), PiConnectionState.active(toggleStatus)],
    );

    blocTest(
      'Emits [$PiConnectionState.loading(), $PiConnectionState.failure] when fetchActivePiholeSettings fails',
      build: () async {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Left(failure));

        return bloc;
      },
      act: (PiConnectionBloc bloc) async => bloc.add(PiConnectionEvent.disable()),
      expect: [PiConnectionState.loading(), PiConnectionState.failure(failure)],
    );

    blocTest(
      'Emits [$PiConnectionState.loading(), $PiConnectionState.failure] when disablePihole fails',
      build: () async {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(settings));
        when(mockConnectionRepository.disablePihole(settings))
            .thenAnswer((_) async => Left(failure));

        return bloc;
      },
      act: (PiConnectionBloc bloc) async => bloc.add(PiConnectionEvent.disable()),
      expect: [PiConnectionState.loading(), PiConnectionState.failure(failure)],
    );
  });
}
