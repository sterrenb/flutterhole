import 'package:flutterhole/service/browser.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/service/memory_tree.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    Globals.tree = MemoryTree();
  });
  test('launchURL', () {
    expect(launchURL('example.com'), completion(false));
  });
}
