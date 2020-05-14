import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
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

  PiholeSettings settings = PiholeSettings(title: 'First');
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

  group('$PiConnectionEventPing', () {
    final settings = PiholeSettings(title: 'First');
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
      expect: [
        PiConnectionState.loading(),
        PiConnectionState.active(settings, toggleStatus)
      ],
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
      act: (PiConnectionBloc bloc) async =>
          bloc.add(PiConnectionEvent.enable()),
      expect: [
        PiConnectionState.loading(),
        PiConnectionState.active(settings, toggleStatus)
      ],
    );

    blocTest(
      'Emits [$PiConnectionState.loading(), $PiConnectionState.failure] when fetchActivePiholeSettings fails',
      build: () async {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Left(failure));

        return bloc;
      },
      act: (PiConnectionBloc bloc) async =>
          bloc.add(PiConnectionEvent.enable()),
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
      act: (PiConnectionBloc bloc) async =>
          bloc.add(PiConnectionEvent.enable()),
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
      act: (PiConnectionBloc bloc) async =>
          bloc.add(PiConnectionEvent.disable()),
      expect: [
        PiConnectionState.loading(),
        PiConnectionState.active(settings, toggleStatus)
      ],
    );

    blocTest(
      'Emits [$PiConnectionState.loading(), $PiConnectionState.failure] when fetchActivePiholeSettings fails',
      build: () async {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Left(failure));

        return bloc;
      },
      act: (PiConnectionBloc bloc) async =>
          bloc.add(PiConnectionEvent.disable()),
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
      act: (PiConnectionBloc bloc) async =>
          bloc.add(PiConnectionEvent.disable()),
      expect: [PiConnectionState.loading(), PiConnectionState.failure(failure)],
    );
  });

  group('$PiConnectionEventSleep', () {
    final settings = PiholeSettings(title: 'Sleepy pi');
    final Duration tDuration = Duration(milliseconds: 100);
    final ToggleStatus afterSleep = ToggleStatus(PiStatusEnum.disabled);
    final ToggleStatus afterWake = ToggleStatus(PiStatusEnum.enabled);
    final DateTime now = clock.now();
    final tFailure = Failure('test #0');

    blocTest(
      'Emits [$PiConnectionStateLoading, $PiConnectionStateSleeping, $PiConnectionStateActive] when $PiConnectionEventSleep succeeds and finishes',
      build: () async {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(settings));
        when(mockConnectionRepository.sleepPihole(settings, tDuration))
            .thenAnswer((_) async => Right(afterSleep));
        when(mockConnectionRepository.pingPihole(settings))
            .thenAnswer((_) async => Right(afterWake));

        return bloc;
      },
      act: (PiConnectionBloc bloc) async =>
          bloc.add(PiConnectionEventSleep(tDuration, now)),
      wait: tDuration * 2,
      expect: [
        PiConnectionStateLoading(),
        PiConnectionStateSleeping(
          settings,
          now,
          tDuration,
        ),
        PiConnectionStateLoading(),
        PiConnectionStateActive(settings, afterWake),
      ],
    );

    blocTest(
      'Emits [$PiConnectionStateLoading, $PiConnectionStateFailure] when $PiConnectionEventSleep fails',
      build: () async {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(settings));
        when(mockConnectionRepository.sleepPihole(settings, tDuration))
            .thenAnswer((_) async => Left(tFailure));

        return bloc;
      },
      act: (PiConnectionBloc bloc) async =>
          bloc.add(PiConnectionEventSleep(tDuration, now)),
      expect: [
        PiConnectionStateLoading(),
        PiConnectionStateFailure(tFailure),
      ],
    );
  });
}
