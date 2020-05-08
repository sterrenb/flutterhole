import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/api/data/repositories/api_repository.dart';
import 'package:flutterhole/features/settings/blocs/pihole_settings_bloc.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/features/settings/data/repositories/settings_repository.dart';
import 'package:mockito/mockito.dart';

import '../../../../test_dependency_injection.dart';

class MockApiRepository extends Mock implements ApiRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  setUpAllForTest();

  ApiRepository mockApiRepository;
  SettingsRepository mockSettingsRepository;
  PiholeSettingsBloc bloc;

  setUp(() {
    mockApiRepository = MockApiRepository();
    mockSettingsRepository = MockSettingsRepository();
    bloc = PiholeSettingsBloc(mockApiRepository, mockSettingsRepository);
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

  group('$PiholeSettingsEventInit', () {
    final PiholeSettings initialValue = PiholeSettings();
    blocTest(
      'Emits [$PiholeSettingsStateEditing] when $PiholeSettingsEventInit succeeds',
      build: () async {
        return bloc;
      },
      act: (PiholeSettingsBloc bloc) async =>
          bloc.add(PiholeSettingsEvent.init(initialValue)),
      expect: [
        PiholeSettingsStateEditing(
          initialValue,
          initialValue,
        )
      ],
    );
  });

  group('$PiholeSettingsEventUpdate', () {
    final PiholeSettings initialValue = PiholeSettings();
    final PiholeSettings currentValue = PiholeSettings(title: 'Current');
    blocTest(
      'Emits [$PiholeSettingsStateFailure] when $PiholeSettingsEventUpdate is called when not in state $PiholeSettingsStateEditing',
      build: () async {
        return bloc;
      },
      act: (PiholeSettingsBloc bloc) async =>
          bloc.add(PiholeSettingsEvent.update(initialValue)),
      expect: [
        PiholeSettingsState.failure(
            Failure('state is not $PiholeSettingsStateEditing')),
      ],
    );

    blocTest(
      'Emits [$PiholeSettingsStateEditing, $PiholeSettingsStateEditing] when $PiholeSettingsEventUpdate is called when in state $PiholeSettingsStateEditing',
      build: () async {
        return bloc;
      },
      act: (PiholeSettingsBloc bloc) async {
        bloc.add(PiholeSettingsEvent.init(initialValue));
        bloc.add(PiholeSettingsEvent.update(currentValue));
      },
      expect: [
        PiholeSettingsState.editing(initialValue, initialValue),
        PiholeSettingsState.editing(initialValue, currentValue),
      ],
    );
  });
}
