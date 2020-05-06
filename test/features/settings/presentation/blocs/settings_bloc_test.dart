import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/api/data/repositories/api_repository.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/features/settings/data/repositories/settings_repository.dart';
import 'package:flutterhole/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:mockito/mockito.dart';

import '../../../../test_dependency_injection.dart';

class MockApiRepository extends Mock implements ApiRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  setUpAllForTest();

  ApiRepository mockApiRepository;
  SettingsRepository mockSettingsRepository;
  SettingsBloc bloc;

  setUp(() {
    mockApiRepository = MockApiRepository();
    mockSettingsRepository = MockSettingsRepository();
    bloc = SettingsBloc(mockApiRepository, mockSettingsRepository);
  });

  tearDown(() {
    bloc.close();
  });

  blocTest(
    'Initially emits InitialSettingsState',
    build: () async => bloc,
    skip: 0,
    expect: [SettingsStateInitial()],
  );

  blocTest(
    'Emits [] when nothing is added',
    build: () async => bloc,
    expect: [],
  );

  group('$SettingsEventInit', () {
    final List<PiholeSettings> all = [
      PiholeSettings(title: 'First'),
      PiholeSettings(title: 'Second'),
    ];
    final active = all.first;

    blocTest(
      'Emits [$SettingsStateLoading, $SettingsStateSuccess] when $SettingsEventInit succeeds',
      build: () async {
        when(mockSettingsRepository.fetchAllPiholeSettings())
            .thenAnswer((_) async => Right(all));
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(active));

        return bloc;
      },
      act: (SettingsBloc bloc) async => bloc.add(SettingsEventInit()),
      expect: [SettingsStateLoading(), SettingsStateSuccess(all, active)],
    );

    blocTest(
      'Emits [$SettingsStateLoading, $SettingsStateFailure] when fetchAllPiholeSettings fails',
      build: () async {
        when(mockSettingsRepository.fetchAllPiholeSettings())
            .thenAnswer((_) async => Left(Failure()));
//        when(mockSettingsRepository.fetchActivePiholeSettings())
//            .thenAnswer((_) async => Right(active));

        return bloc;
      },
      act: (SettingsBloc bloc) async => bloc.add(SettingsEventInit()),
      expect: [SettingsStateLoading(), SettingsStateFailure(Failure())],
    );

    blocTest(
      'Emits [$SettingsStateLoading, $SettingsStateFailure] when fetchActivePiholeSettings fails',
      build: () async {
        when(mockSettingsRepository.fetchAllPiholeSettings())
            .thenAnswer((_) async => Right(all));
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Left(Failure()));

        return bloc;
      },
      act: (SettingsBloc bloc) async => bloc.add(SettingsEventInit()),
      expect: [SettingsStateLoading(), SettingsStateFailure(Failure())],
    );
  });

  group('$SettingsEventReset', () {
    final all = <PiholeSettings>[];
    final active = PiholeSettings();

    blocTest(
      'Emits [$SettingsStateLoading, $SettingsStateSuccess] when $SettingsEventReset succeeds',
      build: () async {
        when(mockSettingsRepository.deleteAllSettings())
            .thenAnswer((_) async => Right(true));
        when(mockSettingsRepository.fetchAllPiholeSettings())
            .thenAnswer((_) async => Right(all));
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(active));

        return bloc;
      },
      act: (SettingsBloc bloc) async => bloc.add(SettingsEventReset()),
      expect: [SettingsStateLoading(), SettingsStateSuccess(all, active)],
    );
  });

  group('$SettingsEventCreate', () {
    final all = <PiholeSettings>[
      PiholeSettings(title: 'First'),
      PiholeSettings(title: 'Second'),
    ];

    final added = PiholeSettings(title: 'Add me');

    blocTest(
      'Emits [$SettingsStateLoading, $SettingsStateSuccess] when $SettingsEventCreate succeeds',
      build: () async {
        when(mockSettingsRepository.createPiholeSettings())
            .thenAnswer((_) async => Right(added));
        when(mockSettingsRepository.fetchAllPiholeSettings())
            .thenAnswer((_) async => Right(all));
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(added));

        return bloc;
      },
      act: (SettingsBloc bloc) async => bloc.add(SettingsEventCreate()),
      expect: [
        SettingsStateLoading(),
        SettingsStateSuccess(all, added)
      ],
    );
  });
}
