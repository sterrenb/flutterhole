import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/service/routes.dart';

import '../mock.dart';

void main() {
  MockRouter router;
  setUp(() {
    router = MockRouter();
  });

  test('paths', () {
    expect(querySearchPath('test'), '/query/search/test');
    expect(clientLogPath('test'), '/query/client/test');
    expect(queryTypeLogPath('test'), '/query/queryType/test');
    expect(queryTypeLogPath('test'), '/query/queryType/test');
    expect(piholeEditPath(mockPiholes.first), '/settings/FlutterHole');
  });

  test('configureRoutes', () {
    configureRoutes(router);
  });
}
