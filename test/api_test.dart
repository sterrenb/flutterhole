import 'package:flutter_hole/models/api_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockApi extends Mock implements ApiProvider {}

void main() {
  group('statusToBool', () {
    test('status: enabled', () {
      expect(ApiProvider.statusToBool({'status': 'enabled'}), true);
    });
    test('status: disabled', () {
      expect(ApiProvider.statusToBool({'status': 'disabled'}), false);
    });
    test('status: unexpected', () {
      expect(() => ApiProvider.statusToBool({'status': 'unexpected'}),
          throwsException);
    });
  });

  group('domain', () {
    test('default hostname', () {
      expect(ApiProvider.domain('pi.hole', '80'), 'http://pi.hole/' + apiPath);
    });
    test('default address', () {
      expect(
          ApiProvider.domain('10.0.1.1', '80'), 'http://10.0.1.1/' + apiPath);
    });
    test('specified port', () {
      expect(ApiProvider.domain('pi.hole', '5000'),
          'http://pi.hole:5000/' + apiPath);
    });
    test('specified host', () {
      expect(ApiProvider.domain('my.hole', '80'), 'http://my.hole/' + apiPath);
    });
  });

  group('fetch', () {

  });
}
