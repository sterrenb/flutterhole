import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:injectable/injectable.dart';

Future<void> setUpAllForTest() async {
  setUpAll(() async {
    await configure(Environment.test);
    TestWidgetsFlutterBinding.ensureInitialized();
  });
}