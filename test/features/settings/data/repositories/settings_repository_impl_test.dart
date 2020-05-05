import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/core/models/exceptions.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/settings/data/datasources/settings_data_source.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:mockito/mockito.dart';

import '../../../../test_dependency_injection.dart';

class MockSettingsDataSource extends Mock implements SettingsDataSource {}

void main() async {
  await setUpAllForTest();

  SettingsRepositoryImpl settingsRepository;
  SettingsDataSource mockSettingsDataSource;
  PiholeSettings piholeSettings;

  setUp(() {
    piholeSettings = PiholeSettings(baseUrl: 'http://example.com');
    mockSettingsDataSource = MockSettingsDataSource();
    settingsRepository = SettingsRepositoryImpl(mockSettingsDataSource);
  });

  group('activatePiholeSettings', () {
    test(
      'should return true on successful activatePiholeSettings',
      () async {
        // arrange
        when(mockSettingsDataSource.activatePiholeSettings(any))
            .thenAnswer((_) async => true);
        // act
        final Either<Failure, bool> result =
            await settingsRepository.activatePiholeSettings(piholeSettings);
        // assert
        expect(result, equals(Right(true)));
      },
    );

    test(
      'should return $Failure on failed activatePiholeSettings',
      () async {
        // arrange
        final tError = PiException.emptyResponse();
        when(mockSettingsDataSource.activatePiholeSettings(any))
            .thenThrow(tError);
        // act
        final Either<Failure, bool> result =
            await settingsRepository.activatePiholeSettings(piholeSettings);
        // assert
        expect(result, equals(Left(Failure())));
      },
    );
  });

  group('createPiholeSettings', () {
    test(
      'should return true on successful createPiholeSettings',
      () async {
        // arrange
        when(mockSettingsDataSource.createPiholeSettings())
            .thenAnswer((_) async => PiholeSettings());
        // act
        final Either<Failure, PiholeSettings> result =
            await settingsRepository.createPiholeSettings();
        // assert
        expect(result, equals(Right(PiholeSettings())));
      },
    );

    test(
      'should return $Failure on failed createPiholeSettings',
      () async {
        // arrange
        final tError = PiException.emptyResponse();
        when(mockSettingsDataSource.createPiholeSettings()).thenThrow(tError);
        // act
        final Either<Failure, PiholeSettings> result =
            await settingsRepository.createPiholeSettings();
        // assert
        expect(result, equals(Left(Failure())));
      },
    );
  });

  group('deletePiholeSettings', () {
    test(
      'should return true on successful deletePiholeSettings',
      () async {
        // arrange
        when(mockSettingsDataSource.deletePiholeSettings(any))
            .thenAnswer((_) async => true);
        // act
        final Either<Failure, bool> result =
            await settingsRepository.deletePiholeSettings(piholeSettings);
        // assert
        expect(result, equals(Right(true)));
      },
    );

    test(
      'should return $Failure on failed deletePiholeSettings',
      () async {
        // arrange
        final tError = PiException.emptyResponse();
        when(mockSettingsDataSource.deletePiholeSettings(any))
            .thenThrow(tError);
        // act
        final Either<Failure, bool> result =
            await settingsRepository.deletePiholeSettings(piholeSettings);
        // assert
        expect(result, equals(Left(Failure())));
      },
    );
  });

  group('fetchAllPiholeSettings', () {
    test(
      'should return true on successful fetchAllPiholeSettings',
      () async {
        // arrange
        final List<PiholeSettings> all = [
          PiholeSettings(title: 'First'),
          PiholeSettings(title: 'Second'),
        ];
        when(mockSettingsDataSource.fetchAllPiholeSettings())
            .thenAnswer((_) async => all);
        // act
        final Either<Failure, List<PiholeSettings>> result =
            await settingsRepository.fetchAllPiholeSettings(piholeSettings);
        // assert
        expect(result, equals(Right(all)));
      },
    );

    test(
      'should return $Failure on failed fetchAllPiholeSettings',
      () async {
        // arrange
        final tError = PiException.emptyResponse();
        when(mockSettingsDataSource.fetchAllPiholeSettings()).thenThrow(tError);
        // act
        final Either<Failure, List<PiholeSettings>> result =
            await settingsRepository.fetchAllPiholeSettings(piholeSettings);
        // assert
        expect(result, equals(Left(Failure())));
      },
    );
  });

  group('updatePiholeSettings', () {
    test(
      'should return true on successful updatePiholeSettings',
      () async {
        // arrange
        when(mockSettingsDataSource.updatePiholeSettings(any))
            .thenAnswer((_) async => true);
        // act
        final Either<Failure, bool> result =
            await settingsRepository.updatePiholeSettings(piholeSettings);
        // assert
        expect(result, equals(Right(true)));
      },
    );

    test(
      'should return $Failure on failed updatePiholeSettings',
      () async {
        // arrange
        final tError = PiException.emptyResponse();
        when(mockSettingsDataSource.updatePiholeSettings(any))
            .thenThrow(tError);
        // act
        final Either<Failure, bool> result =
            await settingsRepository.updatePiholeSettings(piholeSettings);
        // assert
        expect(result, equals(Left(Failure())));
      },
    );
  });

  group('fetchActivePiholeSettings', () {
    test(
      'should return $PiholeSettings on successful fetchActivePiholeSettings',
      () async {
        // arrange
        final PiholeSettings piholeSettings =
            PiholeSettings(title: 'Activated');

        when(mockSettingsDataSource.fetchActivePiholeSettings())
            .thenAnswer((_) async => piholeSettings);
        // act
        final Either<Failure, PiholeSettings> result =
            await settingsRepository.fetchActivePiholeSettings();
        // assert
        expect(result, equals(Right(piholeSettings)));
      },
    );

    test(
      'should return $Failure on failed fetchActivePiholeSettings',
      () async {
        // arrange
        final tError = PiException.emptyResponse();
        when(mockSettingsDataSource.fetchActivePiholeSettings())
            .thenThrow(tError);
        // act
        final Either<Failure, PiholeSettings> result =
            await settingsRepository.fetchActivePiholeSettings();
        // assert
        expect(result, equals(Left(Failure())));
      },
    );
  });
}
