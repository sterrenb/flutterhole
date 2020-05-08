import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/api/data/models/pi_status.dart';
import 'package:flutterhole/features/api/data/repositories/connection_repository.dart';
import 'package:flutterhole/features/settings/blocs/pihole_settings_bloc.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/features/settings/data/repositories/settings_repository.dart';
import 'package:mockito/mockito.dart';

import '../../../../test_dependency_injection.dart';

class MockConnectionRepository extends Mock implements ConnectionRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  setUpAllForTest();

  ConnectionRepository mockConnectionRepository;
  PiholeSettingsBloc bloc;

  setUp(() {
    mockConnectionRepository = MockConnectionRepository();
    bloc = PiholeSettingsBloc(mockConnectionRepository);
  });

  tearDown(() {
    bloc.close();
  });

  blocTest(
    'Initially emits InitialPiholeSettingsState',
    build: () async => bloc,
    skip: 0,
    expect: [PiholeSettingsStateInitial()],
  );

  blocTest(
    'Emits [] when nothing is added',
    build: () async => bloc,
    expect: [],
  );

  group('$PiholeSettingsEventValidate', () {
    final PiholeSettings settings = PiholeSettings();
    blocTest(
      'Emits [$PiholeSettingsStateLoading, $PiholeSettingsStateValidated] when $PiholeSettingsEventValidate succeeds',
      build: () async {
        return bloc;
      },
      act: (PiholeSettingsBloc bloc) async {
        when(mockConnectionRepository.fetchHostStatusCode(settings))
            .thenAnswer((_) async => Right(200));
        when(mockConnectionRepository.fetchPiholeStatus(settings))
            .thenAnswer((_) async => Right(PiStatusEnum.enabled));
        when(mockConnectionRepository.fetchAuthenticatedStatus(settings))
            .thenAnswer((_) async => Right(true));
        bloc.add(PiholeSettingsEvent.validate(settings));
      },
      expect: [
        PiholeSettingsStateLoading(),
        PiholeSettingsStateValidated(
          settings,
          Right(200),
          Right(PiStatusEnum.enabled),
          Right(true),
        )
      ],
    );

    blocTest(
      'Emits [$PiholeSettingsStateLoading, $PiholeSettingsStateValidated] when $PiholeSettingsEventValidate partially succeeds',
      build: () async {
        return bloc;
      },
      act: (PiholeSettingsBloc bloc) async {
        when(mockConnectionRepository.fetchHostStatusCode(settings))
            .thenAnswer((_) async => Right(200));
        when(mockConnectionRepository.fetchPiholeStatus(settings))
            .thenAnswer((_) async => Left(Failure()));
        when(mockConnectionRepository.fetchAuthenticatedStatus(settings))
            .thenAnswer((_) async => Left(Failure()));
        bloc.add(PiholeSettingsEvent.validate(settings));
      },
      expect: [
        PiholeSettingsStateLoading(),
        PiholeSettingsStateValidated(
          settings,
          Right(200),
          Left(Failure()),
          Left(Failure()),
        )
      ],
    );

    blocTest(
      'Emits [$PiholeSettingsStateLoading, $PiholeSettingsStateValidated] when all calls fail',
      build: () async {
        return bloc;
      },
      act: (PiholeSettingsBloc bloc) async {
        when(mockConnectionRepository.fetchHostStatusCode(settings))
            .thenAnswer((_) async => Left(Failure()));
        when(mockConnectionRepository.fetchPiholeStatus(settings))
            .thenAnswer((_) async => Left(Failure()));
        when(mockConnectionRepository.fetchAuthenticatedStatus(settings))
            .thenAnswer((_) async => Left(Failure()));
        bloc.add(PiholeSettingsEvent.validate(settings));
      },
      expect: [
        PiholeSettingsStateLoading(),
        PiholeSettingsStateValidated(
          settings,
          Left(Failure()),
          Left(Failure()),
          Left(Failure()),
        )
      ],
    );
  });
}
