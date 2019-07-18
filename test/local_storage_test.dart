import 'package:fimber/fimber.dart';
import 'package:flutter/services.dart';
import 'package:flutterhole/model/pihole.dart';
import 'package:flutterhole/service/local_storage.dart';
import "package:test/test.dart";

void mockSharedPreferences({List<Pihole> piholes = const []}) async {
  Map<String, dynamic> piholeValues = {};

  piholes.forEach((pihole) {
    final values = pihole.toJson();
    values.forEach((String key, dynamic value) {
      piholeValues['flutter.$piholePrefix${pihole.localKey}_$key'] = value;
    });
  });

  MethodChannel('plugins.flutter.io/shared_preferences')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'getAll') {
      return piholeValues;
    }
    if (methodCall.method == 'clear') {
      piholeValues.clear();
      return true;
    }
    return null;
  });
}

void main() {
  LocalStorage localStorage;
  Fimber.plantTree(DebugTree());

  setUp(() async {
    mockSharedPreferences();
    localStorage = await LocalStorage.getInstance();
    LocalStorage.clear();
  });

  test('initially empty', () async {
    localStorage = await LocalStorage.getInstance();
    expect(localStorage.cache, {});
  });

  test('clear removes all keys', () async {
    expect(LocalStorage.clear(), completes);
    expectLater(localStorage.cache, isEmpty);
  });

  group('clear', () {
    test('reset on empty cache results in cache with 1 pihole', () async {
      mockSharedPreferences();
      await localStorage.reset();

      final pihole = Pihole();
      expect(localStorage.cache, {pihole.localKey: pihole});
    });

    test('reset on existing cache results in cache with 1 pihole', () async {
      mockSharedPreferences(
          piholes: [Pihole(title: 'one'), Pihole(title: 'two')]);
      await localStorage.reset();

      final pihole = Pihole();
      expect(localStorage.cache, {pihole.localKey: pihole});
    });
  });

  group('remove', () {
    test('successful remove results in new map', () async {
      final pihole = Pihole();
      mockSharedPreferences(piholes: [pihole]);
      await localStorage.init();

      assert(localStorage.cache[pihole.localKey] == pihole);

      final bool didRemove = await localStorage.remove(pihole);
      expect(didRemove, isTrue);
      expect(localStorage.cache, {Pihole().localKey: Pihole()});
    });

    test('invalid remove results in false', () async {
      final pihole = Pihole(title: 'staying around');
      mockSharedPreferences(piholes: [pihole]);
      await localStorage.init();

      assert(localStorage.cache[pihole.localKey] == pihole);

      final bool didRemove =
          await localStorage.remove(Pihole.copyWith(pihole, title: 'unknown'));
      expect(didRemove, isFalse);
      expect(localStorage.cache, {pihole.localKey: pihole});
    });
  });

  group('add', () {
    test('successful add returns true', () async {
      final pihole = Pihole();
      await localStorage.init();
      assert(localStorage.cache.length == 0);

      final bool didAdd = await localStorage.add(pihole);
      expect(didAdd, isTrue);
      expect(localStorage.cache, {pihole.localKey: pihole});
    });

    test('duplicate add returns false', () async {
      final pihole = Pihole();
      mockSharedPreferences(piholes: [pihole]);
      await localStorage.init();

      assert(localStorage.cache.length == 1);

      final bool didAdd = await localStorage.add(pihole);
      expect(didAdd, isFalse);
      expect(localStorage.cache, {pihole.localKey: pihole});
    });
  });

  group('update', () {
    test('successful update without key change', () async {
      final pihole = Pihole(title: 'updating');
      final update = Pihole.copyWith(pihole, port: 8080);
      mockSharedPreferences(piholes: [pihole]);
      await localStorage.init();

      assert(localStorage.cache.length == 1);

      await localStorage.update(pihole, update);

      expect(localStorage.cache[pihole.localKey], update);
    });

    test('successful update with key change', () async {
      final pihole = Pihole(title: 'updating');
      final update =
          Pihole.copyWith(pihole, title: 'edited', host: 'edited host');
      mockSharedPreferences(piholes: [pihole]);
      await localStorage.init();

      assert(localStorage.cache.length == 1);

      await localStorage.update(pihole, update);

      expect(localStorage.cache.containsKey(pihole.localKey), isFalse);
      expect(localStorage.cache[update.localKey], update);
      expect(localStorage.cache.length, 1);
    });

    test('update with conflicting key change throws Exception', () async {
      final pihole = Pihole();
      final update = Pihole(title: 'already present', host: 'edited host');
      mockSharedPreferences(piholes: [pihole, update]);
      await localStorage.init();

      assert(localStorage.cache.length == 2);

      try {
        await localStorage.update(pihole, update);
        fail('exception not thrown');
      } catch (e) {
        expect(e, TypeMatcher<Exception>());
      }
    });
  });

  group('activate', () {
    test('invalid activate throws Exception', () async {
      final pihole = Pihole();
      mockSharedPreferences(piholes: [pihole]);
      await localStorage.init();

      try {
        await localStorage.activate(Pihole(title: 'unknown'));
        fail('exception not thrown');
      } catch (e) {
        expect(e, isException);
      }
    });
  });
}
