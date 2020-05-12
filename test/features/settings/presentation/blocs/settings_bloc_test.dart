import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/features/settings/data/repositories/settings_repository.dart';
import 'package:flutterhole/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:mockito/mockito.dart';

import '../../../../test_dependency_injection.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  setUpAllForTest();

  SettingsRepository mockSettingsRepository;
  SettingsBloc bloc;

  setUp(() {
    mockSettingsRepository = MockSettingsRepository();
    bloc = SettingsBloc(mockSettingsRepository);
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
      expect: [SettingsStateLoading(), SettingsStateSuccess(all, added)],
    );
  });

  group('$SettingsEventAdd', () {
    final added = PiholeSettings(title: 'Add me');

    final all = <PiholeSettings>[
      PiholeSettings(title: 'First'),
      PiholeSettings(title: 'Second'),
      added,
    ];

    blocTest(
      'Emits [$SettingsStateLoading, $SettingsStateSuccess] when $SettingsEventAdd succeeds',
      build: () async {
        when(mockSettingsRepository.addPiholeSettings(added))
            .thenAnswer((_) async => Right(true));
        when(mockSettingsRepository.fetchAllPiholeSettings())
            .thenAnswer((_) async => Right(all));
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(all.first));

        return bloc;
      },
      act: (SettingsBloc bloc) async => bloc.add(SettingsEventAdd(added)),
      expect: [SettingsStateLoading(), SettingsStateSuccess(all, all.first)],
    );
  });

  group('$SettingsEventActivate', () {
    final settings0 = PiholeSettings(title: 'First');
    final settings1 = PiholeSettings(title: 'Second');
    final settings2 = PiholeSettings(title: 'Third');

    final newActive = settings1;

    blocTest(
      'Emits [$SettingsStateLoading, $SettingsStateSuccess] when $SettingsEventActivate succeeds',
      build: () async {
        when(mockSettingsRepository.activatePiholeSettings(newActive))
            .thenAnswer((_) async => Right(true));
        when(mockSettingsRepository.fetchAllPiholeSettings())
            .thenAnswer((_) async => Right([
                  newActive,
                  settings0,
                  settings2,
                ]));
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(newActive));
        return bloc;
      },
      act: (SettingsBloc bloc) async =>
          bloc.add(SettingsEvent.activate(newActive)),
      expect: [
        SettingsStateLoading(),
        SettingsStateSuccess([
          newActive,
          settings0,
          settings2,
        ], newActive)
      ],
    );
  });

  group('$SettingsEventDelete', () {
    final settings0 = PiholeSettings(title: 'Delete me');
    final settings1 = PiholeSettings(title: 'Second');
    final settings2 = PiholeSettings(title: 'Third');

    final deleteMe = settings1;

    blocTest(
      'Emits [$SettingsStateLoading, $SettingsStateSuccess] when $SettingsEventDelete succeeds',
      build: () async {
        when(mockSettingsRepository.deletePiholeSettings(deleteMe))
            .thenAnswer((_) async => Right(true));
        when(mockSettingsRepository.fetchAllPiholeSettings())
            .thenAnswer((_) async => Right([
                  deleteMe,
                  settings0,
                  settings2,
                ]));
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(deleteMe));
        return bloc;
      },
      act: (SettingsBloc bloc) async =>
          bloc.add(SettingsEvent.delete(deleteMe)),
      expect: [
        SettingsStateLoading(),
        SettingsStateSuccess([
          deleteMe,
          settings0,
          settings2,
        ], deleteMe)
      ],
    );
  });

  group('$SettingsEventUpdate', () {
    final settings0 = PiholeSettings(title: 'First');
    final settings1 = PiholeSettings(title: 'Second');
    final settings2 = PiholeSettings(title: 'Third');

    final updated = settings0.copyWith(title: 'Updated');

    blocTest(
      'Emits [$SettingsStateLoading, $SettingsStateSuccess] when $SettingsEventUpdate succeeds',
      build: () async {
        when(mockSettingsRepository.updatePiholeSettings(settings0, updated))
            .thenAnswer((_) async => Right(true));
        when(mockSettingsRepository.fetchAllPiholeSettings())
            .thenAnswer((_) async => Right([
                  updated,
                  settings1,
                  settings2,
                ]));
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(settings2));
        return bloc;
      },
      act: (SettingsBloc bloc) async =>
          bloc.add(SettingsEvent.update(settings0, updated)),
      expect: [
        SettingsStateLoading(),
        SettingsStateSuccess(
          [
            updated,
            settings1,
            settings2,
          ],
          settings2,
        )
      ],
    );
  });
}
