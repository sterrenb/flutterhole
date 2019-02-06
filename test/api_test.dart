import 'package:flutter_hole/models/api.dart';
import 'package:test/test.dart';

void main() {
  group('statusToBool', () {
    test('status: enabled', () {
      expect(Api.statusToBool({'status': 'enabled'}), true);
    });
    test('status: disabled', () {
      expect(Api.statusToBool({'status': 'disabled'}), false);
    });
    test('status: unexpected', () {
      expect(() => Api.statusToBool({'status': 'unexpected'}), throwsException);
    });
  });
}
