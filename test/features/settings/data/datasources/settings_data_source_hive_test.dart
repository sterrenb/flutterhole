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
  Box mockPiBox;
  Box mockActiveBox;

  await setUpAllForTest();

  setUp(() {
    mockHive = MockHive();
    mockPiBox = MockBox();
    mockActiveBox = MockBox();
    when(mockHive.openBox(KStrings.piholeSettingsSubDirectory))
        .thenAnswer((_) async => mockPiBox);
    when(mockHive.openBox(KStrings.piholeSettingsActive))
        .thenAnswer((_) async => mockActiveBox);
    settingsDataSourceHive = SettingsDataSourceHive(mockHive);
  });

  group('createPiholeSettings', () {
    test(
      'should return PiholeSettings on successful createPiholeSettings',
      () async {
        // arrange
        when(mockPiBox.isOpen).thenReturn(true);
        when(mockPiBox.length).thenReturn(123);
        final PiholeSettings piholeSettings =
            PiholeSettings(title: 'Pihole #123');
        // act
        final PiholeSettings result =
            await settingsDataSourceHive.createPiholeSettings();
        // assert
        expect(result, equals(piholeSettings));
        verify(mockPiBox.add(piholeSettings.toJson()));
      },
    );

    test(
      'should throw SettingsException on createPiholeSettings with closed box',
      () async {
        // arrange
        when(mockPiBox.isOpen).thenReturn(false);
        // assert
        expect(() => settingsDataSourceHive.createPiholeSettings(),
            throwsA(isA<SettingsException>()));
      },
    );
  });

  group('addPiholeSettings', () {
    test(
      'should return PiholeSettings on successful addPiholeSettings',
      () async {
        // arrange
        when(mockPiBox.isOpen).thenReturn(true);
        when(mockPiBox.length).thenReturn(123);
        final PiholeSettings piholeSettings =
            PiholeSettings(title: 'Pihole #124');
        // act
        final bool result =
            await settingsDataSourceHive.addPiholeSettings(piholeSettings);
        // assert
        expect(result, isTrue);
        verify(mockPiBox.add(piholeSettings.toJson()));
      },
    );

    test(
      'should throw SettingsException on addPiholeSettings with closed box',
      () async {
        // arrange
        when(mockPiBox.isOpen).thenReturn(false);
        final PiholeSettings piholeSettings =
            PiholeSettings(title: 'Pihole #124'); // assert
        expect(() => settingsDataSourceHive.addPiholeSettings(piholeSettings),
            throwsA(isA<SettingsException>()));
      },
    );
  });

  group('updatePiholeSettings', () {
    test(
      'should return PiholeSettings on successful updatePiholeSettings',
      () async {
        // arrange
        final PiholeSettings original = PiholeSettings(
          title: 'Original',
          apiPort: 123,
        );
        final PiholeSettings updated = original.copyWith(title: 'Updated');

        when(mockPiBox.isOpen).thenReturn(true);
        when(mockPiBox.values).thenReturn([original.toJson()]);

        // act
        await settingsDataSourceHive.updatePiholeSettings(original, updated);
        // assert
        verify(mockPiBox.putAt(0, updated.toJson()));
      },
    );

    test(
      'should throw SettingsException on updatePiholeSettings with empty settings title',
      () async {
        // arrange
        final PiholeSettings original = PiholeSettings(title: '');
        final PiholeSettings update = original.copyWith(title: 'oi');
        // assert
        expect(
            () => settingsDataSourceHive.updatePiholeSettings(original, update),
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
        when(mockPiBox.isOpen).thenReturn(true);
        when(mockPiBox.values).thenReturn([
          PiholeSettings().toJson(),
          piholeSettings.toJson(),
        ]);

        when(mockPiBox.deleteAt(1)).thenAnswer((_) async {});
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
        when(mockPiBox.isOpen).thenReturn(true);

        when(mockPiBox.deleteFromDisk()).thenAnswer((_) async {});
        // act
        await settingsDataSourceHive.deleteAllSettings();
        // assert
        verify(mockHive.deleteFromDisk());
      },
    );
  });

  group('activatePiholeSettings', () {
    test(
      'should return true on successful activatePiholeSettings',
      () async {
        // arrange
        final settings0 = PiholeSettings(title: 'First');
        final settings1 = PiholeSettings(title: 'Second');
        final settings2 = PiholeSettings(title: 'Third');

        final all = <PiholeSettings>[
          settings0,
          settings1,
          settings2,
        ];

        final newActive = settings2;

        when(mockPiBox.isOpen).thenReturn(true);
        when(mockActiveBox.isOpen).thenReturn(true);
        when(mockPiBox.values).thenReturn(all.map((e) => e.toJson()).toList());
        // act
        final result =
            await settingsDataSourceHive.activatePiholeSettings(newActive);
        // assert
        expect(result, isTrue);
      },
    );
  });

  group('fetchAllPiholeSettings', () {
    test(
      'should return List<PiholeSettings> on successful fetchAllPiholeSettings',
      () async {
        // arrange
        when(mockPiBox.isOpen).thenReturn(true);
        final allPiholeSettings = <PiholeSettings>[
          PiholeSettings(title: 'First'),
          PiholeSettings(
              title: 'Second', basicAuthenticationPassword: 'password'),
          PiholeSettings(
            title: 'Last',
            apiPort: 123,
          ),
        ];
        when(mockPiBox.values)
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
        when(mockPiBox.isOpen).thenReturn(false);
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
        when(mockPiBox.isOpen).thenReturn(true);
        when(mockPiBox.getAt(2)).thenReturn(active.toJson());
        when(mockActiveBox.isOpen).thenReturn(true);
        when(mockActiveBox.get(KStrings.piholeSettingsActive, defaultValue: -1))
            .thenReturn(2);
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

        when(mockPiBox.isOpen).thenReturn(true);
        when(mockPiBox.values)
            .thenReturn(allPiholeSettings.map((e) => e.toJson()));
        when(mockActiveBox.isOpen).thenReturn(true);
        when(mockActiveBox.get(KStrings.piholeSettingsActive, defaultValue: -1))
            .thenReturn(-1);
        // act
        final PiholeSettings result =
            await settingsDataSourceHive.fetchActivePiholeSettings();
        // assert
        expect(result, equals(PiholeSettings()));
      },
    );
  });
}
