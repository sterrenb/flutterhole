import 'package:flutter_test/flutter_test.dart' as flutter_test;
import 'package:flutterhole/dependency_injection.dart';
import 'package:injectable/injectable.dart';

Future<void> setUpAllForTest() async {
  flutter_test.setUpAll(() async {
    await configure(Environment.test);
    flutter_test.TestWidgetsFlutterBinding.ensureInitialized();
  });
}