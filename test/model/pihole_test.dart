import 'package:flutterhole/model/pihole.dart';
import "package:test/test.dart";

main() {
  group('pihole', () {
    Pihole pihole;

    setUp(() {
      pihole = Pihole();
    });

    test('constructor', () {
      expect(pihole.title, 'FlutterHole');
      expect(pihole.host, 'pi.hole');
      expect(pihole.apiPath, 'admin/api.php');
      expect(pihole.port, 80);
      expect(pihole.auth, isEmpty);
      expect(pihole.useSSL, isFalse);
      expect(pihole.allowSelfSigned, isFalse);
    });

    test('copyWith', () {
      final Pihole copied = Pihole.copyWith(pihole, title: 'new', port: 123);
      final Pihole expected = Pihole(title: 'new', port: 123);
      expect(copied == expected, isTrue);
    });

    test('toJson', () {
      expect(pihole.toJson(), {
        'title': 'FlutterHole',
        'host': 'pi.hole',
        'apipath': 'admin/api.php',
        'port': '80',
        'auth': '',
        'useSSL': 'false',
        'allowSelfSigned': 'false',
        'proxy_host': '',
        'proxy_port': '8080',
        'proxy_username': '',
        'proxy_password': '',
      });
    });

    test('getters', () {
      expect(pihole.localKey, 'FlutterHole');
      expect(pihole.baseUrl, 'http://pi.hole');
      expect(Pihole.toKey(pihole.title), 'FlutterHole');
    });
  });

  group('proxy', () {
    Proxy proxy;

    setUp(() {
      proxy = Proxy(
        host: 'host',
        port: 8080,
        username: 'user',
        password: 'pass',
      );
    });

    test('constructor', () {
      expect(proxy.host, 'host');
      expect(proxy.port, 8080);
      expect(proxy.username, 'user');
      expect(proxy.password, 'pass');
    });

    test('copyWith', () {
      final Proxy copied1 = Proxy.copyWith(proxy, host: 'new', port: 123);
      expect(copied1,
          Proxy(host: 'new', port: 123, username: 'user', password: 'pass'));

      final Proxy copied2 = Proxy.copyWith(
          proxy, username: 'hi', password: 'bye');
      expect(copied2,
          Proxy(host: 'host', port: 8080, username: 'hi', password: 'bye'));
    });

    test('getters', () {
      expect(proxy.directConnection, 'host:8080');
      expect(proxy.basicAuth, 'dXNlcjpwYXNz');
    });
  });
}
