import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:sterrenburg.github.flutterhole/api_provider.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/shared_preferences',
  );

  const Map<String, dynamic> kTestValues = <String, dynamic>{
    'flutter.hostname': 'hello world',
    'flutter.port': 80,
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
      expect(ApiProvider.domain('pi.hole', 80), 'http://pi.hole/' + apiPath);
    });
    test('default address', () {
      expect(
          ApiProvider.domain('10.0.1.1', 80), 'http://10.0.1.1/' + apiPath);
    });
    test('specified port', () {
      expect(ApiProvider.domain('pi.hole', 5000),
          'http://pi.hole:5000/' + apiPath);
    });
    test('specified host', () {
      expect(ApiProvider.domain('my.hole', 80), 'http://my.hole/' + apiPath);
    });
  });

  group('fetch', () {
    test('default', () async {
      final MockClient client = MockClient((request) async {
        return Response('test', 200);
      });
      final response = await ApiProvider(client: client).fetch('params');
      expect(response.body, 'test');
    });
    test('timeout', () async {
      final MockClient client = MockClient((request) async {
        await Future.delayed(Duration(seconds: 10), () {});
        return Response('test', 200);
      });
      expect(ApiProvider(client: client).fetch('params'), throwsException);
    });
  });

  group('fetchEnabled', () {
    test('true', () async {
      final MockClient client = MockClient((request) async {
        return Response(json.encode({'status': 'enabled'}), 200);
      });
      final bool response = await ApiProvider(client: client).fetchEnabled();
      expect(response, true);
    });
    test('false', () async {
      final MockClient client = MockClient((request) async {
        return Response(json.encode({'status': 'disabled'}), 200);
      });
      final bool response = await ApiProvider(client: client).fetchEnabled();
      expect(response, false);
    });
  });

  group('setStatus', () {
    test('true valid auth', () async {
      final MockClient client = MockClient((request) async {
        return Response(json.encode({'status': 'disabled'}), 200);
      });
      final bool response = await ApiProvider(client: client).setStatus(true);
      expect(response, false);
    });
    test('true no auth', () async {
      final MockClient client = MockClient((request) async {
        return Response('[]', 403);
      });
      expect(
              () => ApiProvider(client: client).setStatus(true),
          throwsException);
    });
  });
  group('isAuthorized', () {
    test('authorized', () async {
      final MockClient client = MockClient((request) async {
        return Response('valid', 200);
      });
      final bool response = await ApiProvider(client: client).isAuthorized();
      expect(response, true);
    });
    test('not authorized', () async {
      final MockClient client = MockClient((request) async {
        return Response('[]', 403);
      });
      final bool response = await ApiProvider(client: client).isAuthorized();
      expect(response, false);
    });
  });
}
