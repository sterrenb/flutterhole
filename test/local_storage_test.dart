import 'package:flutter/services.dart';
import 'package:flutterhole_again/model/pihole.dart';
import 'package:flutterhole_again/repository/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:test/test.dart";

void mockSharedPreferences({Map<String, dynamic> map}) {
  if (map == null) {
    map = {};
  } else {
    print('using map titled ${map[titleKey]}');
    final String title = map[titleKey];
    map = map.map((String key, dynamic value) => MapEntry<String, dynamic>(
        'flutter.$piholePrefix${title.toLowerCase().replaceAll(' ', '_')}_$key',
        value));
  }

  const MethodChannel('plugins.flutter.io/shared_preferences')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'getAll') {
      return map;
    }
    return null;
  });
}

void main() {
  LocalStorage localStorage;

  setUp(() {
    LocalStorage.reset().then((_) {
      mockSharedPreferences();
    });
  });

  test('initially empty', () async {
    localStorage = await LocalStorage.getInstance();
    expect(localStorage.cache, {});
  });

  group('save', () {
    test('succesful save stores the keys and updates the cache', () async {
      localStorage = await LocalStorage.getInstance();
      final preferences = await SharedPreferences.getInstance();
      final pihole = Pihole();

      await localStorage.save(pihole);

      expect(localStorage.cache['flutterhole'], pihole);
      expect(
          preferences.getKeys(),
          Set<String>.from([
            'pihole_user_flutterhole_title',
            'pihole_user_flutterhole_host',
            'pihole_user_flutterhole_port',
            'pihole_user_flutterhole_auth'
          ]));
    });

    test('succesful double save stores the keys and updates the cache',
        () async {
      localStorage = await LocalStorage.getInstance();
      final preferences = await SharedPreferences.getInstance();
      assert(preferences.getKeys().length == 0);
      final piholeA = Pihole(title: 'The coolest');
      final piholeB = Pihole(
        title: 'A cool test',
      );

      await localStorage.save(piholeA);
      await localStorage.save(piholeB);

      expect(localStorage.cache[piholeA.key], piholeA);
      expect(localStorage.cache[piholeB.key], piholeB);
    });

    test('duplicate save throws Exception', () async {
      final pihole = Pihole(title: 'no dupes allowed');

      mockSharedPreferences(map: pihole.toJson());

      localStorage = await LocalStorage.getInstance();
      assert(localStorage.cache[pihole.key] == pihole);

      try {
        await localStorage.save(pihole);
        fail('exception not thrown');
      } catch (e) {
        expect(e, TypeMatcher<Exception>());
      }

      expect(localStorage.cache[pihole.key], pihole);
    });
  });

  group('activate', () {
    test('succesful activate updates the cache', () async {
      final pihole = Pihole();

      mockSharedPreferences(map: pihole.toJson());

      localStorage = await LocalStorage.getInstance();
      assert(localStorage.cache[pihole.key] == pihole);

      await localStorage.activate(pihole.key);

      expect(localStorage.active, pihole);
    });
  });
}
