import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/pihole_api/blocs/extras_bloc.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_extras.dart';
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
  ExtrasBloc bloc;

  setUp(() {
    settings = PiholeSettings(title: 'First', apiToken: 'token');
    mockApiRepository = MockApiRepository();
    mockSettingsRepository = MockSettingsRepository();
    bloc = ExtrasBloc(mockApiRepository, mockSettingsRepository);
  });

  tearDown(() {
    bloc.close();
  });

  blocTest<ExtrasBloc, ExtrasState>(
    'Emits [] when nothing is added',
    build: () => bloc,
    expect: [],
  );

  group('fetch', () {
    final PiExtras extras = PiExtras(
      temperature: 12.34,
      load: [14, 15, 16],
      memoryUsage: 54.23,
    );
    blocTest<ExtrasBloc, ExtrasState>(
      'Emits [loading, success] on success',
      build: () {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(settings));
        when(mockApiRepository.fetchExtras(any))
            .thenAnswer((_) async => Right(extras));
        bloc.add(ExtrasEvent.fetch());
        return bloc;
      },
      expect: [
        ExtrasState.loading(),
        ExtrasState.success(extras),
      ],
    );

    final failure = Failure('oh no');
    blocTest<ExtrasBloc, ExtrasState>(
      'Emits [loading, failure] on failure',
      build: () {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(settings));
        when(mockApiRepository.fetchExtras(any))
            .thenAnswer((_) async => left(failure));
        bloc.add(ExtrasEvent.fetch());
        return bloc;
      },
      expect: [
        ExtrasState.loading(),
        ExtrasState.failure(failure),
      ],
    );
  });
}
