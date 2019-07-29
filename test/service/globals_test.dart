import 'package:fluro/fluro.dart';
import 'package:flutterhole/service/globals.dart';
import "package:test/test.dart";

void main() {
  test('navigateTo', () async {
    Globals.router = Router();
    expect(Globals.navigateTo(null, '/'), throwsException);
  });
}
