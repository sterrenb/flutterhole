import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> setUpAllForTest() async {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // expose path_provider
    // https://github.com/flutter/flutter/issues/10912#issuecomment-587403632
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/path_provider');
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return ".";
    });

    // https://github.com/Baseflow/flutter_cached_network_image/issues/50#issuecomment-582714900
    SharedPreferences.setMockInitialValues({});

    await configure(Environment.test);
  });
}
