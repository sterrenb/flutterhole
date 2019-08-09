import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutterhole/model/api/blacklist.dart';
import 'package:flutterhole/model/api/query.dart';
import 'package:flutterhole/model/api/status.dart';
import 'package:flutterhole/model/pihole.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/service/pihole_client.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:mockito/mockito.dart';
import "package:test/test.dart";

import '../mock.dart';

typedef MockAdapterHandler = ResponseBody Function(RequestOptions options);

class MockAdapter extends DefaultHttpClientAdapter {
  List<MockAdapterHandler> handlers;

  MockAdapter([this.handlers = const []]);

  factory MockAdapter.string(String str) => MockAdapter([
        (_) {
          return ResponseBody.fromString(str, 200);
        }
      ]);

  factory MockAdapter.emptyString() => MockAdapter([
        (_) {
          return ResponseBody.fromString('', 200);
        }
      ]);

  factory MockAdapter.notAuthorized() => MockAdapter.string('Not authorized!');

  factory MockAdapter.json(dynamic data) => MockAdapter([
        (_) {
          return ResponseBody.fromString(json.encode(data), 200);
        }
      ]);

  factory MockAdapter.throwsError({dynamic e}) => MockAdapter([
        (_) {
          throw e ?? DioError();
        }
      ]);

  factory MockAdapter.emptyList() => MockAdapter([
        (_) {
          return ResponseBody.fromString('[]', 200);
        }
      ]);

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<List<int>> requestStream, Future cancelFuture) async {
    ResponseBody response;

    for (final handler in handlers) {
      response = handler(options);
      if (response != null) return response;
    }

    throw UnimplementedError();
//    return handler(options);
  }
}

void main() {
  Pihole pihole;
  Dio dio;
  MockSecureStore secureStore;
  PiholeClient client;

  setUp(() async {
    Globals.tree = MockMemoryTree();
    pihole = Pihole(
      title: 'Testing',
      host: 'test',
      auth: 'test_token',
    );

    dio = Dio(BaseOptions(
      baseUrl: pihole.baseUrl,
    ));
    dio.httpClientAdapter = MockAdapter();

    secureStore = MockSecureStore();
    secureStore.active = pihole;

    client = PiholeClient(dio: dio, secureStore: secureStore);
  });

  test('constructor', () {
    expect(client.dio.interceptors.isNotEmpty, isTrue);
  });

  test('cancel', () {
    final initialToken = client.token;
    expect(initialToken, isNotNull);
    client.cancel();
    expect(client.token == initialToken, isFalse);
  });

  group('fetchSummary', () {
    test('returns on successful summary fetch', () async {
      dio.httpClientAdapter = MockAdapter.json(mockSummary.toJson());
      expect(client.fetchSummary(), completion(mockSummary));
    });

    test('self signed', () async {
      dio.httpClientAdapter = MockAdapter.json(mockSummary.toJson());
      secureStore.active = Pihole.copyWith(pihole, allowSelfSigned: true);
      try {
        await client.fetchSummary();
        fail('exception not thrown');
      } catch (_) {}
    });
  });

  group('proxy', () {
    test('direct connection', () {
      secureStore.active = Pihole(
          host: 'proxy',
          proxy: Proxy(
            host: 'proxy.com',
            port: 8080,
          ));
      dio.httpClientAdapter = MockAdapter.json(mockSummary.toJson());

      expect(client.fetchSummary(), completion(mockSummary));
    });

    test('basic auth', () {
      secureStore.active = Pihole(
          host: 'basic',
          proxy: Proxy(
            username: 'user',
            password: 'pass',
          ));
      dio.httpClientAdapter = MockAdapter.json(mockSummary.toJson());

      expect(client.fetchSummary(), completion(mockSummary));
    });
  });

  group('fetchForwardDestinations', () {
    test('returns on successful forwardDestinations fetch', () async {
      dio.httpClientAdapter =
          MockAdapter.json(mockForwardDestinations.toJson());
      expect(client.fetchForwardDestinations(),
          completion(mockForwardDestinations));
    });
  });

  group('fetchStatus', () {
    test('returns Status on successful response', () async {
      dio.httpClientAdapter = MockAdapter.json(mockStatusEnabled.toJson());
      expect(client.fetchStatus(), completion(Status(enabled: true)));
    });

    test('throws PiholeException on empty response', () async {
      dio.httpClientAdapter = MockAdapter.emptyList();
      try {
        await client.fetchStatus();
        fail('exception not thrown');
      } on PiholeException catch (e) {
        expect(e.message, 'empty response');
      }
    });

    test('throws PiholeException on unresolved hostname', () async {
      dio.httpClientAdapter = MockAdapter.throwsError();
      try {
        await client.fetchStatus();
        fail('exception not thrown');
      } on PiholeException catch (e) {
        expect(e.e, TypeMatcher<DioError>());
      }
    });

    test('throws PiholeException on not authorized response', () async {
      dio.httpClientAdapter = MockAdapter.notAuthorized();
      try {
        await client.fetchStatus();
        fail('exception not thrown');
      } on PiholeException catch (e) {
        expect(e.message, 'not authorized');
      }
    });
  });

  group('enable', () {
    test('returns Status enabled on successful enable', () async {
      dio.httpClientAdapter = MockAdapter.json(mockStatusEnabled.toJson());
      expect(client.enable(), completion(mockStatusEnabled));
    });

    test('logs warning when API token is empty', () async {
      secureStore.active = Pihole.copyWith(pihole, auth: '');
      dio.httpClientAdapter = MockAdapter.json(mockStatusEnabled.toJson());

      await client.enable();
      verify(Globals.tree.log(
          'client', 'API token is empty (only showing warning once)',
          tag: 'warning'));
//      expect(Globals.tree.logs.first.logLine, 'API token is empty (only showing warning once)');
    });

    test('throws PiholeException on disabled response', () async {
      dio.httpClientAdapter = MockAdapter.json(mockStatusDisabled.toJson());
      try {
        await client.enable();
        fail('exception not thrown');
      } on PiholeException catch (e) {
        expect(e.message, 'failed to enable');
      }
    });
  });

  group('disable', () {
    test('returns on successful response disabled', () async {
      dio.httpClientAdapter = MockAdapter.json(mockStatusDisabled.toJson());
      expect(client.disable(), completion(mockStatusDisabled));
    });

    test('throws PiholeException on enabled response', () async {
      dio.httpClientAdapter = MockAdapter.json(mockStatusEnabled.toJson());
      try {
        await client.disable();
        fail('exception not thrown');
      } on PiholeException catch (e) {
        expect(e.message, 'failed to disable');
      }
    });
  });

  group('fetchTopItems', () {
    test('returns TopItems on successful response', () async {
      dio.httpClientAdapter = MockAdapter.json(mockTopItems.toJson());
      expect(client.fetchTopItems(), completion(mockTopItems));
    });

    test('throws PiholeException on plaintext response', () async {
      dio.httpClientAdapter = MockAdapter.string('<!-- hello -->');
      try {
        await client.fetchTopItems();
        fail('exception not thrown');
      } on PiholeException catch (e) {
        expect(e.message.contains('unexpected plaintext response'), isTrue);
      }
    });
  });

  group('blacklist', () {
    group('fetchBlacklist', () {
      test('returns Blacklist on successful response', () async {
        dio.httpClientAdapter = MockAdapter.json(mockBlacklist.toJson());
        expect(client.fetchBlacklist(), completion(mockBlacklist));
      });
    });

    group('addToBlacklist', () {
      test('returns on successful exact add', () async {
        dio.httpClientAdapter = MockAdapter.emptyString();
        final BlacklistItem toAdd = BlacklistItem.exact(entry: 'example');

        expect(client.addToBlacklist(toAdd), completes);
      });

      test('returns on successful wildcard add', () async {
        dio.httpClientAdapter = MockAdapter.emptyString();
        final BlacklistItem toAdd = BlacklistItem.wildcard(entry: 'wild');

        expect(client.addToBlacklist(toAdd), completes);
      });

      test('returns on successful regex add', () async {
        dio.httpClientAdapter = MockAdapter.emptyString();
        final BlacklistItem toAdd = BlacklistItem.regex(entry: 'regex');

        expect(client.addToBlacklist(toAdd), completes);
      });

      test('throws PiholeException on duplicate blacklist add', () async {
        dio.httpClientAdapter = MockAdapter.string('no need to add');
        final BlacklistItem toAdd = BlacklistItem.exact(entry: 'a.com');

        try {
          await client.addToBlacklist(toAdd);
          fail('exception not thrown');
        } on PiholeException catch (e) {
          expect(e.message.contains('already exists'), isTrue);
        }
      });

      test('throws PiholeException on invalid blacklist add', () async {
        dio.httpClientAdapter = MockAdapter.string('not a valid domain');
        final BlacklistItem toAdd = BlacklistItem.exact(entry: 'invalid');

        try {
          await client.addToBlacklist(toAdd);
          fail('exception not thrown');
        } on PiholeException catch (e) {
          expect(e.message.contains('${toAdd.entry} is not a valid domain'),
              isTrue);
        }
      });
    });

    group('editOnBlacklist', () {
      test('returns on successful blacklist edit', () async {
        dio.httpClientAdapter = MockAdapter.emptyString();
        expect(
            client.editOnBlacklist(
                BlacklistItem(
                    entry: 'wildcard.com', type: BlacklistType.Wildcard),
                BlacklistItem(
                    entry: 'wildcard.edited.com',
                    type: BlacklistType.Wildcard)),
            completes);
      });
    });

    group('removeFromBlacklist', () {
      test('returns on successful exact remove', () async {
        dio.httpClientAdapter = MockAdapter.emptyString();
        expect(
            client.removeFromBlacklist(
                BlacklistItem(entry: 'example.com', type: BlacklistType.Exact)),
            completes);
      });
    });
  });

  group('whitelist', () {
    group('fetchWhitelist', () {
      test('returns Whitelist on successful fetch', () async {
        dio.httpClientAdapter = MockAdapter.string(mockWhitelist.toJson());
        final whitelist = await client.fetchWhitelist();
        expect(whitelist, mockWhitelist);
      });
    });

    group('addToWhitelist', () {
      test('returns on succesful add', () async {
        dio.httpClientAdapter =
            MockAdapter.string('adding new.com to whitelist...');
        expect(client.addToWhitelist('new.com'), completes);
      });

      test('throws PiholeException on duplicate add', () async {
        dio.httpClientAdapter =
            MockAdapter.string('already exists in whitelist');
        try {
          await client.addToWhitelist('new.com');
          fail('exception not thrown');
        } on PiholeException catch (e) {
          expect(e.message, 'new.com is already whitelisted');
        }
      });

      test('throws PiholeException on empty add', () async {
        try {
          await client.addToWhitelist('');
          fail('exception not thrown');
        } on PiholeException catch (e) {
          expect(e.message, 'cannot add empty domain to whitelist');
        }
      });

      test('throws PiholeException on unexpected response', () async {
        dio.httpClientAdapter = MockAdapter.string('hello');
        try {
          await client.addToWhitelist('new.com');
          fail('exception not thrown');
        } on PiholeException catch (e) {
          expect(e.message, 'unexpected whitelist response');
        }
      });

      test('throws PiholeException on unauthorized add', () async {
        dio.httpClientAdapter = MockAdapter.notAuthorized();
        try {
          await client.addToWhitelist('new.com');
          fail('exception not thrown');
        } on PiholeException catch (e) {
          expect(e.message, 'not authorized');
        }
      });
    });

    group('removeFromWhitelist', () {
      test('throws PiholeException on empty removeFromWhitelist', () async {
        dio.httpClientAdapter = MockAdapter.notAuthorized();
        try {
          await client.removeFromWhitelist('');
          fail('exception not thrown');
        } on PiholeException catch (e) {
          expect(e.message, 'cannot remove empty domain from whitelist');
        }
      });

      test('throws PiholeException on unauthorized removeFromWhitelist',
          () async {
        dio.httpClientAdapter = MockAdapter.notAuthorized();
        try {
          await client.removeFromWhitelist('new.com');
          fail('exception not thrown');
        } on PiholeException catch (e) {
          expect(e.message, 'not authorized');
        }
      });
    });

    group('editOnWhitelist', () {
      test('returns on successful edit', () async {
        dio.httpClientAdapter =
            MockAdapter.string('adding new.com to whitelist...');
        expect(client.editOnWhitelist('original.com', 'new.com'), completes);
      });
    });
  });

  group('fetchTopSources', () {
    test('returns TopSources on successful fetch', () async {
      dio.httpClientAdapter = MockAdapter.json(mockTopSources.toJson());
      expect(client.fetchTopSources(), completion(mockTopSources));
    });
  });

  group('fetchVersions', () {
    test('returns Versions on successful fetch', () async {
      dio.httpClientAdapter = MockAdapter.json(mockVersions.toJson());
      expect(client.fetchVersions(), completion(mockVersions));
    });
  });

  group('fetchQueries', () {
    test('returns Queries on successful fetch', () async {
      dio.httpClientAdapter =
          MockAdapter.json(mockQueries.map((query) => query.toJson()).toList());
      expect(client.fetchQueries(), completion(mockQueries));
    });
  });

  group('fetchQueriesForClient', () {
    test('returns Queries on successful fetch', () async {
      dio.httpClientAdapter =
          MockAdapter.json(mockQueries.map((query) => query.toJson()).toList());
      expect(client.fetchQueriesForClient('client'), completion(mockQueries));
    });
  });

  group('fetchQueriesForQueryType', () {
    test('returns Queries on successful fetch', () async {
      dio.httpClientAdapter =
          MockAdapter.json(mockQueries.map((query) => query.toJson()).toList());
      expect(client.fetchQueriesForQueryType(QueryType.A),
          completion(mockQueries));
    });
  });

  group('fetchQueryTypes', () {
    test('returns QueryTypes on successful fetch', () async {
      dio.httpClientAdapter = MockAdapter.json(mockQueryTypes.toJson());
      expect(client.fetchQueryTypes(), completion(mockQueryTypes));
    });
  });

  group('fetchQueriesOverTime', () {
    test('returns QueriesOverTime on successful fetch', () async {
      dio.httpClientAdapter = MockAdapter.json(mockQueriesOverTime.toJson());
      expect(client.fetchQueriesOverTime(), completion(mockQueriesOverTime));
    });
  });

  group('fetchClientsOverTime', () {
    test('returns ClientsOverTime on successful fetch', () async {
      dio.httpClientAdapter = MockAdapter.json(mockClientsOverTime.toJson());
      expect(client.fetchClientsOverTime(), completion(mockClientsOverTime));
    });
  });

  group('fetchClientNames', () {
    test('returns ClientNames on successful fetch', () async {
      dio.httpClientAdapter = MockAdapter.json(mockClientNames.toJson());
      expect(client.fetchClientNames(), completion(mockClientNames));
    });
  });
}
