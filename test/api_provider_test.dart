import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:sterrenburg.github.flutterhole/api_provider.dart';
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
      expect(ApiProvider.domain('pi.hole', 80), 'pi.hole');
    });
    test('default address', () {
      expect(ApiProvider.domain('10.0.1.1', 80), '10.0.1.1');
    });
    test('specified port', () {
      expect(ApiProvider.domain('pi.hole', 5000), 'pi.hole:5000');
    });
    test('ssl port', () {
      expect(ApiProvider.domain('pi.hole', 443), 'pi.hole:443');
    });
    test('specified host', () {
      expect(ApiProvider.domain('my.hole', 80), 'my.hole');
    });
  });

  group('launchURL', () {
    test('valid', () async {
      expect(ApiProvider().launchURL('http://pi.hole'), completion(false));
    });
    test('invalid', () async {
      expect(ApiProvider().launchURL('ftp://pi.hole'), completion(false));
    });
  });

  group('fetch', () {
    test('valid query', () async {
      final MockClient client = MockClient((request) async {
        return Response('test', 200);
      });
      final response = await ApiProvider(client: client).fetch({});
      expect(response.body, 'test');
    });
    test('500', () async {
      final MockClient client = MockClient((request) async {
        return Response('test', 500);
      });
      expect(ApiProvider(client: client).fetch({}), throwsException);
    });
    test('timeout', () async {
      final MockClient client = MockClient((request) async {
        await Future.delayed(Duration(seconds: 10), () {});
        return Response('test', 200);
      });
      expect(ApiProvider(client: client).fetch({}), throwsException);
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
    test('enable valid auth', () async {
      final MockClient client = MockClient((request) async {
        return Response(json.encode({'status': 'disabled'}), 200);
      });
      final bool response = await ApiProvider(client: client).setStatus(true);
      expect(response, false);
    });
    test('enable no auth', () async {
      final MockClient client = MockClient((request) async {
        return Response('[]', 403);
      });
      expect(
              () => ApiProvider(client: client).setStatus(true),
          throwsException);
    });
    test('disable for duration', () async {
      final MockClient client = MockClient((request) async {
        return Response(json.encode({'status': 'disabled'}), 200);
      });
      final bool response = await ApiProvider(client: client)
          .setStatus(false, duration: Duration(seconds: 10));
      expect(response, false);
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
  group('fetchSummary', () {
    test('valid response', () async {
      final SummaryModel summaryModel = SummaryModel(
          totalQueries: 1,
          queriesBlocked: 2,
          percentBlocked: 3.4,
          domainsOnBlocklist: 5);

      final MockClient client = MockClient((request) async {
        return Response(jsonEncode(summaryModel.toJson()), 200);
      });
      final SummaryModel summaryModelResult =
      await ApiProvider(client: client).fetchSummary();
      expect(summaryModelResult.totalQueries, summaryModel.totalQueries);
      expect(summaryModelResult.queriesBlocked, summaryModel.queriesBlocked);
      expect(summaryModelResult.percentBlocked, summaryModel.percentBlocked);
      expect(summaryModelResult.domainsOnBlocklist,
          summaryModel.domainsOnBlocklist);
    });
    test('invalid summary', () async {
      final MockClient client = MockClient((request) async {
        return Response(jsonEncode({'invalidKey': 'hi'}), 200);
      });
//    final SummaryModel summaryModelResult = await ApiProvider(client: client).fetchSummary();
      expect(ApiProvider(client: client).fetchSummary(), throwsException);
    });
    test('empty', () async {
      final MockClient client = MockClient((request) async {
        return Response('', 200);
      });
//    final SummaryModel summaryModelResult = await ApiProvider(client: client).fetchSummary();
      expect(ApiProvider(client: client).fetchSummary(), throwsException);
    });
  });

  group('recentlyBlocked', () {
    test('valid response', () {
      final MockClient client = MockClient((request) async {
        return Response('blocked.domain', 200);
      });
      expect(ApiProvider(client: client).recentlyBlocked(),
          completion('blocked.domain'));
    });

    test('invalid response', () {
      final MockClient client = MockClient((request) async {
        return Response('', 500);
      });
      expect(ApiProvider(client: client).recentlyBlocked(), throwsException);
    });
  });
}
