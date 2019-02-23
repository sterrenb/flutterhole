import 'package:flutter/services.dart';
import 'package:sterrenburg.github.flutterhole/pi_config.dart';
import 'package:test/test.dart';

void main() {
  const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/shared_preferences',
  );

  const Map<String, dynamic> kTestValues = <String, dynamic>{
    'flutter.' + PiConfig.allKey: PiConfig.defaultAll,
    'flutter.' + PiConfig.activeKey: PiConfig.defaultActive,
  };

  final List<MethodCall> log = <MethodCall>[];

  setUp(() async {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall);
      if (methodCall.method == 'getAll') {
        return kTestValues;
      }
      return null;
    });
    log.clear();
  });

  test('getActiveIndex', () {
    expect(PiConfig().getActiveIndex(), completion(PiConfig.defaultActive));
  });
  group('getAll', () {
    test('valid', () {
      expect(PiConfig().getAll(), completion(PiConfig.defaultAll));
    });
    test('not set', () {
      expect(PiConfig().getAll(key: 'empty'), completion(PiConfig.defaultAll));
    });
  });
  test('getActiveString', () {
    expect(PiConfig().getActiveString(),
        completion(PiConfig.defaultAll.first)); // PiConfig.defaultAll.first
  });
  test('setActiveIndex', () {
    expect(PiConfig().setActiveIndex(0), completion(false));
  });
}
