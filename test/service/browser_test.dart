import 'package:flutterhole/service/browser.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:test/test.dart';

import '../mock.dart';

void main() {
  setUp(() {
    Globals.tree = MockMemoryTree();
  });
  test('launchURL', () {
    expect(launchURL('example.com'), completion(false));
  });
}
