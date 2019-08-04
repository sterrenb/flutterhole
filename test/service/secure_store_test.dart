import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutterhole/model/pihole.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/service/secure_store.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../mock.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  Map<String, String> map;
  MockFlutterSecureStorage storage;
  SecureStore secureStore;
  Pihole pihole;
  Map<String, String> mockMap;

  setUp(() {
    Globals.tree = MockMemoryTree();
    map = {};
    storage = MockFlutterSecureStorage();
    when(storage.readAll()).thenAnswer((_) => Future.value(map));
    secureStore = SecureStore(storage);
    pihole = Pihole();

    mockMap = {
      'pihole_FirstConfig_useSSL': 'false',
      'pihole_FirstConfig_proxy_host': '',
      'pihole_second_port': '80',
      'pihole_second_apipath': 'admin/api.php',
      'pihole_FirstConfig_auth': '',
      'pihole_FirstConfig_allowSelfSigned': 'false',
      'pihole_second_proxy_port': '8080',
      'pihole_FirstConfig_apipath': 'admin/api.php',
      'pihole_second_proxy_username': 'user',
      'pihole_second_title': 'second',
      'pihole_second_useSSL': 'false',
      'pihole_FirstConfig_host': 'pi.hole',
      'pihole_second_proxy_password': 'pass',
      'pihole_second_proxy_host': 'proxy.host',
      'active_pihole': 'second',
      'pihole_second_allowSelfSigned': 'false',
      'pihole_second_auth': '',
      'pihole_FirstConfig_port': '80',
      'pihole_FirstConfig_title': 'FirstConfig',
      'pihole_FirstConfig_proxy_password': '',
      'pihole_second_host': 'second.com',
      'pihole_FirstConfig_proxy_username': '',
      'pihole_FirstConfig_proxy_port': '8080'
    };
  });

  test('constructor', () {
    expect(secureStore.map, isNull);
    expect(secureStore.piholes, {});
    expect(secureStore.active, isNull);
  });

  group('reload', () {
    test('active is set to `second` with known active in storage', () async {
      map = mockMap;
      when(storage.read(key: activePiholeKey))
          .thenAnswer((_) => Future.value('second'));

      await secureStore.reload();
      final active = Pihole(
          title: 'second',
          host: 'second.com',
          proxy: Proxy(
            host: 'proxy.host',
            username: 'user',
            password: 'pass',
          ));
      expect(secureStore.piholes, {
        'FirstConfig': Pihole(title: 'FirstConfig'),
        'second': active,
      });
      expect(secureStore.active, active);
    });

    test('active is set to last loaded Pihole with unknown active in storage',
        () async {
      map = mockMap;

      await secureStore.reload();
      expect(secureStore.piholes, {
        'FirstConfig': Pihole(title: 'FirstConfig'),
        'second': Pihole(
            title: 'second',
            host: 'second.com',
            proxy: Proxy(
              host: 'proxy.host',
              username: 'user',
              password: 'pass',
            )),
      });
      expect(secureStore.active, Pihole(title: 'FirstConfig'));
    });

    test(
        'active is set to default Pihole with unknown active and no piholes in storage',
        () async {
      await secureStore.reload();
      expect(secureStore.piholes, {
        'FlutterHole': Pihole(),
      });
      expect(secureStore.active, Pihole());
    });
  });

  test('get reads value if not in map', () {
    when(storage.read(key: anyNamed('key')))
        .thenAnswer((_) => Future.value('value'));
    expect(secureStore.get('pihole_key'), completion('value'));
  });

  group('remove', () {
    setUp(() {
      secureStore.piholes = {pihole.title: pihole};
    });
    test('returns on valid remove', () async {
      await secureStore.remove(pihole);
    });

    test('returns on non existant remove', () async {
      await secureStore.remove(Pihole(title: 'unknown'));
    });

    test('returns on storage exception', () async {
      when(storage.delete(key: anyNamed('key'))).thenThrow(Exception());
      await secureStore.remove(Pihole());
    });
  });

  group('add', () {
    test('returns on valid add', () async {
      await secureStore.add(pihole);
      expect(secureStore.piholes, {pihole.title: pihole});
    });

    test('returns on duplicate add with allowOverride', () async {
      await secureStore.add(pihole, allowOverride: true);
      expect(secureStore.piholes, {pihole.title: pihole});
    });

    test('returns on storage exception', () async {
      when(storage.delete(key: anyNamed('key'))).thenThrow(Exception());
      await secureStore.add(Pihole(title: 'new'));
    });

    test('returns on storage exception', () async {
      when(storage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenThrow(Exception());
      await secureStore.add(Pihole(title: 'new'));
    });

    test('throws on duplicate add', () async {
      secureStore.piholes = {pihole.title: pihole};
      try {
        await secureStore.add(pihole);
        fail('exception not thrown');
      } catch (e) {
        expect(
            e.toString(),
            Exception(
                    'FlutterHole already present - if this was intended, set `allowOverride = true`')
                .toString());
      }
    });

    test('returns on non existant remove', () async {
      await secureStore.remove(Pihole(title: 'unknown'));
    });

    test('returns on storage exception', () async {
      when(storage.delete(key: anyNamed('key'))).thenThrow(Exception());
      expect(secureStore.remove(Pihole()), completes);
    });
  });

  group('update', () {
    test('returns on valid update', () async {
      await secureStore.update(Pihole(), Pihole(title: 'new'));
    });

    test('returns on valid update when already active', () async {
      when(storage.read(key: activePiholeKey))
          .thenAnswer((_) => Future.value(Pihole().title));
      await secureStore.activate(Pihole());
      await secureStore.update(Pihole(), Pihole(title: 'new'));
    });

    test('returns on equal update', () async {
      expect(secureStore.update(Pihole(), Pihole()), completes);
    });

    test('throws on update with already present title', () async {
      secureStore.piholes = {'present': Pihole(title: 'present')};
      expect(secureStore.update(Pihole(), Pihole(title: 'present')),
          throwsException);
    });

//    test('updates active when original was active', () async {
//      secureStore.piholes = {'original': Pihole(title: 'original')};
//      when(storage.read(key: activePiholeKey))
//          .thenAnswer((_) => Future.value('original'));
//
//      await secureStore.update(Pihole(title: 'original'), Pihole());
//      expect(secureStore.active, Pihole());
//    });
  });

  test('deleteAll', () async {
    await secureStore.deleteAll();
    expect(secureStore.piholes, isEmpty);
    expect(secureStore.active, isNull);
  });

  test('activate uncached pihole', () async {
    await secureStore.activate(pihole);
    expect(secureStore.active, pihole);
  });
}
