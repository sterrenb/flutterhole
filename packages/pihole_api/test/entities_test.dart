import 'package:dio/dio.dart';
import 'package:pihole_api/pihole_api.dart';
import 'package:test/test.dart';

void main() async {
  late PiholeRepositoryParams params;
  late Dio dio;

  setUp(() {
    dio = Dio();
    params = PiholeRepositoryParams(
      dio: dio,
      baseUrl: "pi.hole",
      useSsl: false,
      apiPath: "/admin/api.php",
      apiPort: 80,
      apiTokenRequired: true,
      apiToken: "token",
      allowSelfSignedCertificates: false,
      adminHome: "/admin",
    );
  });

  group('dioBase', () {
    test('default dioBase should be valid', () {
      expect(params.dioBase, "http://pi.hole");
    });

    test('dioBase should handle SSL', () {
      params = params.copyWith(useSsl: true, apiPort: 443);
      expect(params.dioBase, "https://pi.hole");
    });

    test('dioBase should handle ports', () {
      params = params.copyWith(apiPort: 123);
      expect(params.dioBase, "http://pi.hole:123");
      params = params.copyWith(apiPort: 321);
      expect(params.dioBase, "http://pi.hole:321");
    });
  });
}
