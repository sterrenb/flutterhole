import 'package:flutterhole/model/pihole.dart';
import "package:test/test.dart";

main() {
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
      'allowSelfSigned': 'false',
      'proxy_host': '',
      'proxy_port': '8080',
      'proxy_username': '',
      'proxy_password': '',
    });
  });

  test('getters', () {
    expect(pihole.localKey, 'FlutterHole');
    expect(pihole.baseUrl, 'pi.hole');
    expect(pihole.basePath, 'pi.hole/admin/api.php');
    expect(Pihole.toKey(pihole.title), 'FlutterHole');
  });
}
