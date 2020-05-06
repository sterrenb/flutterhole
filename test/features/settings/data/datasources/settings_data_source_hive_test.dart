import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/features/settings/data/datasources/settings_data_source.dart';
import 'package:flutterhole/features/settings/data/datasources/settings_data_source_hive.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:hive/hive.dart';
import 'package:mockito/mockito.dart';

import '../../../../test_dependency_injection.dart';

class MockHive extends Mock implements HiveInterface {}

class MockBox extends Mock implements Box {}

void main() async {
  SettingsDataSourceHive settingsDataSourceHive;
  HiveInterface mockHive;
  Box mockBox;

  await setUpAllForTest();

  setUp(() {
    mockHive = MockHive();
    mockBox = MockBox();
    when(mockHive.openBox(Constants.piholeSettingsSubDirectory))
        .thenAnswer((_) async => mockBox);
    settingsDataSourceHive = SettingsDataSourceHive(mockHive);
  });

  group('createPiholeSettings', () {
    test(
      'should return PiholeSettings on successful createPiholeSettings',
      () async {
        // arrange
        when(mockBox.isOpen).thenReturn(true);
        when(mockBox.length).thenReturn(123);
        final PiholeSettings piholeSettings =
            PiholeSettings(title: 'Pihole #123');
        // act
        final PiholeSettings result =
            await settingsDataSourceHive.createPiholeSettings();
        // assert
        expect(result, equals(piholeSettings));
        verify(mockBox.add(piholeSettings.toJson()));
      },
    );

    test(
      'should throw SettingsException on createPiholeSettings with closed box',
      () async {
        // arrange
        when(mockBox.isOpen).thenReturn(false);
        // assert
        expect(() => settingsDataSourceHive.createPiholeSettings(),
            throwsA(isA<SettingsException>()));
      },
    );
  });

  group('updatePiholeSettings', () {
    test(
      'should return PiholeSettings on successful updatePiholeSettings',
      () async {
        // arrange
        when(mockBox.isOpen).thenReturn(true);
        final PiholeSettings piholeSettings = PiholeSettings(title: 'Updated');
        // act
        await settingsDataSourceHive.updatePiholeSettings(piholeSettings);
        // assert
        verify(mockBox.putAt(0, piholeSettings.toJson()));
      },
    );

    test(
      'should throw SettingsException on updatePiholeSettings with empty settings title',
      () async {
        // arrange
        final PiholeSettings piholeSettings = PiholeSettings(title: '');
        // assert
        expect(
            () => settingsDataSourceHive.updatePiholeSettings(piholeSettings),
            throwsA(isA<SettingsException>()));
      },
    );
  });

  group('deletePiholeSettings', () {
    test(
      'should return on successful deletePiholeSettings',
      () async {
        // arrange
        final PiholeSettings piholeSettings =
            PiholeSettings(title: 'Delete me');
        when(mockBox.isOpen).thenReturn(true);
        when(mockBox.values).thenReturn([
          PiholeSettings().toJson(),
          piholeSettings.toJson(),
        ]);

        when(mockBox.deleteAt(1)).thenAnswer((_) async {});
        // act
        await settingsDataSourceHive.deletePiholeSettings(piholeSettings);
        // assert
      },
    );
  });

  group('deleteAllSettings', () {
    test(
      'should return on successful deleteAllSettings',
      () async {
        // arrange
        when(mockBox.isOpen).thenReturn(true);

        when(mockBox.deleteFromDisk()).thenAnswer((_) async {});
        // act
        await settingsDataSourceHive.deleteAllSettings();
        // assert
        verify(mockHive.deleteFromDisk());
      },
    );
  });

  test(
    'should return on successful activatePiholeSettings',
    () async {
      // arrange
      when(mockBox.isOpen).thenReturn(true);
      final PiholeSettings piholeSettings =
          PiholeSettings(title: 'Activate me');
      when(mockBox.putAt(0, piholeSettings.toJson())).thenAnswer((_) async {});
      // act
      final result =
          await settingsDataSourceHive.activatePiholeSettings(piholeSettings);
      // assert
      expect(result, isTrue);
    },
  );

  group('fetchAllPiholeSettings', () {
    test(
      'should return List<PiholeSettings> on successful fetchAllPiholeSettings',
      () async {
        // arrange
        when(mockBox.isOpen).thenReturn(true);
        final allPiholeSettings = <PiholeSettings>[
          PiholeSettings(title: 'First'),
          PiholeSettings(
              title: 'Second', basicAuthenticationPassword: 'password'),
          PiholeSettings(
            title: 'Last',
            apiPort: 123,
          ),
        ];
        when(mockBox.values)
            .thenReturn(allPiholeSettings.map((e) => e.toJson()).toList());
        // act
        final result = await settingsDataSourceHive.fetchAllPiholeSettings();
        // assert
        expect(result, equals(allPiholeSettings));
      },
    );

    test(
      'should throw SettingsException on fetchAllPiholeSettings with closed box',
      () async {
        // arrange
        when(mockBox.isOpen).thenReturn(false);
        // assert
        expect(() => settingsDataSourceHive.fetchAllPiholeSettings(),
            throwsA(isA<SettingsException>()));
      },
    );
  });

  group('fetchActivePiholeSettings', () {
    test(
      'should return PiholeSettings on succesful fetchActivePiholeSettings',
      () async {
        // arrange
        final PiholeSettings active = PiholeSettings(title: 'First');
        when(mockBox.isOpen).thenReturn(true);
        when(mockBox.getAt(0)).thenReturn(active.toJson());
        // act
        final PiholeSettings result =
            await settingsDataSourceHive.fetchActivePiholeSettings();
        // assert
        expect(result, equals(active));
      },
    );

    test(
      'should return PiholeSettings on null fetchActivePiholeSettings',
      () async {
        // arrange
        final List<PiholeSettings> allPiholeSettings = <PiholeSettings>[
          PiholeSettings(title: 'First'),
          PiholeSettings(
              title: 'Second', basicAuthenticationPassword: 'password'),
          PiholeSettings(
            title: 'Last',
            apiPort: 123,
          ),
        ];

        when(mockBox.isOpen).thenReturn(true);
        when(mockBox.values)
            .thenReturn(allPiholeSettings.map((e) => e.toJson()));

        // act
        final PiholeSettings result =
            await settingsDataSourceHive.fetchActivePiholeSettings();
        // assert
        expect(result, equals(PiholeSettings()));
      },
    );
  });
}
