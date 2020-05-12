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
        expect(result,
            equals(Left(Failure('activatePiholeSettings failed', tError))));
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
        expect(result,
            equals(Left(Failure('createPiholeSettings failed', tError))));
      },
    );
  });

  group('addPiholeSettings', () {
    test(
      'should return true on successful addPiholeSettings',
          () async {
        // arrange
        when(mockSettingsDataSource.addPiholeSettings(piholeSettings))
            .thenAnswer((_) async => true);
        // act
        final Either<Failure, bool> result =
        await settingsRepository.addPiholeSettings(piholeSettings);
        // assert
        expect(result, equals(Right(true)));
      },
    );

    test(
      'should return $Failure on failed addPiholeSettings',
          () async {
        // arrange
        final tError = PiException.emptyResponse();
        when(mockSettingsDataSource.addPiholeSettings(piholeSettings)).thenThrow(tError);
        // act
        final Either<Failure, bool> result =
        await settingsRepository.addPiholeSettings(piholeSettings);
        // assert
        expect(result,
            equals(Left(Failure('addPiholeSettings failed', tError))));
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
        expect(result,
            equals(Left(Failure('deletePiholeSettings failed', tError))));
      },
    );
  });

  group('deleteAllSettings', () {
    test(
      'should return true on successful deleteAllSettings',
      () async {
        // arrange
        when(mockSettingsDataSource.deleteAllSettings())
            .thenAnswer((_) async => true);
        // act
        final Either<Failure, bool> result =
            await settingsRepository.deleteAllSettings();
        // assert
        expect(result, equals(Right(true)));
      },
    );

    test(
      'should return $Failure on failed deleteAllSettings',
      () async {
        // arrange
        final tError = PiException.emptyResponse();
        when(mockSettingsDataSource.deleteAllSettings()).thenThrow(tError);
        // act
        final Either<Failure, bool> result =
            await settingsRepository.deleteAllSettings();
        // assert
        expect(
            result, equals(Left(Failure('deleteAllSettings failed', tError))));
      },
    );
  });

  group('fetchAllPiholeSettings', () {
    final tSettings = PiholeSettings(title: 'Newly created');

    test(
      'should return List<PiholeSettings> on successful fetchAllPiholeSettings',
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
            await settingsRepository.fetchAllPiholeSettings();
        // assert
        expect(result, equals(Right(all)));
      },
    );

    test(
      'should add default settings to list on successful empty fetchAllPiholeSettings',
      () async {
        // arrange
        final List<PiholeSettings> all = [];
        when(mockSettingsDataSource.fetchAllPiholeSettings())
            .thenAnswer((_) async => all);
        when(mockSettingsDataSource.createPiholeSettings())
            .thenAnswer((_) async => tSettings);
        when(mockSettingsDataSource.activatePiholeSettings(tSettings))
            .thenAnswer((_) async => true);
        // act
        final Either<Failure, List<PiholeSettings>> result =
            await settingsRepository.fetchAllPiholeSettings();
        // assert
        expect(result.isRight(), isTrue);

        result.fold(
          (l) {
            fail('expected List<PiholeSettings>');
          },
          (r) {
            expect(r, equals([tSettings]));
          },
        );

        verify(mockSettingsDataSource.createPiholeSettings());
        verify(mockSettingsDataSource.activatePiholeSettings(tSettings));
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
            await settingsRepository.fetchAllPiholeSettings();
        // assert
        expect(result,
            equals(Left(Failure('fetchAllPiholeSettings failed', tError))));
      },
    );
  });

  group('updatePiholeSettings', () {
    test(
      'should return true on successful updatePiholeSettings',
      () async {
        // arrange
        when(mockSettingsDataSource.updatePiholeSettings(any, any))
            .thenAnswer((_) async => true);
        // act
        final Either<Failure, bool> result = await settingsRepository
            .updatePiholeSettings(piholeSettings, piholeSettings);
        // assert
        expect(result, equals(Right(true)));
      },
    );

    test(
      'should return $Failure on failed updatePiholeSettings',
      () async {
        // arrange
        final tError = PiException.emptyResponse();
        when(mockSettingsDataSource.updatePiholeSettings(any, any))
            .thenThrow(tError);
        // act
        final Either<Failure, bool> result = await settingsRepository
            .updatePiholeSettings(piholeSettings, piholeSettings);
        // assert
        expect(result,
            equals(Left(Failure('updatePiholeSettings failed', tError))));
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
        final tError = PiException.timeOut();
        when(mockSettingsDataSource.fetchActivePiholeSettings())
            .thenThrow(tError);
        // act
        final Either<Failure, PiholeSettings> result =
            await settingsRepository.fetchActivePiholeSettings();
        // assert
        expect(result,
            equals(Left(Failure('fetchActivePiholeSettings failed', tError))));
        verifyNever(mockSettingsDataSource.createPiholeSettings());
      },
    );
  });
}
