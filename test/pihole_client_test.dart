import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutterhole_again/model/blacklist.dart';
import 'package:flutterhole_again/model/pihole.dart';
import 'package:flutterhole_again/model/status.dart';
import 'package:flutterhole_again/model/summary.dart';
import 'package:flutterhole_again/model/whitelist.dart';
import 'package:flutterhole_again/service/local_storage.dart';
import 'package:flutterhole_again/service/pihole_client.dart';
import 'package:flutterhole_again/service/pihole_exception.dart';
import 'package:mockito/mockito.dart';
import "package:test/test.dart";

class MockLocalStorage extends Mock implements LocalStorage {}

final mockSummary = Summary(
    domainsBeingBlocked: 0,
    dnsQueriesToday: 1,
    adsBlockedToday: 2,
    adsPercentageToday: 2.345,
    uniqueDomains: 3,
    queriesForwarded: 4,
    queriesCached: 5,
    clientsEverSeen: 6,
    uniqueClients: 7,
    dnsQueriesAllTypes: 8,
    replyNodata: 9,
    replyNxdomain: 10,
    replyCname: 11,
    replyIp: 12,
    privacyLevel: 13,
    status: 'enabled',
    gravityLastUpdated: GravityLastUpdated(
        fileExists: true,
        absolute: 14,
        relative: Relative(days: '15', hours: '16', minutes: '17')));

final mockStatusEnabled = Status(enabled: true);
final mockStatusDisabled = Status(enabled: false);

final mockWhitelist = Whitelist(list: ['a.com', 'b.org', 'c.net']);
final mockBlacklist = Blacklist(exact: [
  BlacklistItem.exact(entry: 'exact.com'),
  BlacklistItem.exact(entry: 'pi-hole.net'),
], wildcard: [
  BlacklistItem.wildcard(entry: 'wildcard.com'),
  BlacklistItem.regex(entry: 'regex')
]);

typedef MockAdapterHandler = ResponseBody Function(RequestOptions options);

class MockAdapter extends HttpClientAdapter {
  List<MockAdapterHandler> handlers;

  MockAdapter([this.handlers = const []]);

  factory MockAdapter.string(String str) =>
      MockAdapter([
            (_) {
          return ResponseBody.fromString(str, 200);
        }
      ]);

  factory MockAdapter.emptyString() =>
      MockAdapter([
            (_) {
          return ResponseBody.fromString('', 200);
        }
      ]);

  factory MockAdapter.notAuthorized() => MockAdapter.string('Not authorized!');

  factory MockAdapter.throwsError({dynamic e}) =>
      MockAdapter([
            (_) {
          throw e ?? DioError();
        }
      ]);

  factory MockAdapter.emptyList() =>
      MockAdapter([
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
  LocalStorage localStorage;
  PiholeClient client;

  setUp(() async {
    pihole = Pihole(
      title: 'Testing',
      host: 'test',
      auth: 'test_token',
    );

    dio = Dio(BaseOptions(
      baseUrl: pihole.baseUrl,
    ));
    dio.httpClientAdapter = MockAdapter();

    localStorage = MockLocalStorage();
    when(localStorage.active()).thenReturn(pihole);

    client = PiholeClient(dio: dio, localStorage: localStorage);
  });

  test('constructor', () {
    expect(client.dio.interceptors.isNotEmpty, isTrue);
  });

  group('fetchStatus', () {
    test('returns Status on successful response', () async {
      dio.httpClientAdapter =
          MockAdapter.string(json.encode(mockStatusEnabled.toJson()));
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
      dio.httpClientAdapter =
          MockAdapter.string(json.encode(mockStatusEnabled.toJson()));
      expect(client.enable(), completion(mockStatusEnabled));
    });

    test('throws PiholeException when API token is empty', () async {
      pihole.auth = '';
      try {
        await client.enable();
        fail('exception not thrown');
      } on PiholeException catch (e) {
        expect(e.message, 'API token is empty');
      }
    });

    test('throws PiholeException on disabled response', () async {
      dio.httpClientAdapter =
          MockAdapter.string(json.encode(mockStatusDisabled.toJson()));
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
      dio.httpClientAdapter =
          MockAdapter.string(json.encode(mockStatusDisabled.toJson()));
      expect(client.disable(), completion(mockStatusDisabled));
    });

    test('throws PiholeException on enabled response', () async {
      dio.httpClientAdapter =
          MockAdapter.string(json.encode(mockStatusEnabled.toJson()));
      try {
        await client.disable();
        fail('exception not thrown');
      } on PiholeException catch (e) {
        expect(e.message, 'failed to disable');
      }
    });
  });

  group('fetchSummary', () {
    test('returns Summary on successful response', () async {
      dio.httpClientAdapter =
          MockAdapter.string(json.encode(mockSummary.toJson()));
      expect(client.fetchSummary(), completion(mockSummary));
    });

    test('throws PiholeException on plaintext response', () async {
      dio.httpClientAdapter = MockAdapter.string('<!-- hello -->');
      try {
        await client.fetchSummary();
        fail('exception not thrown');
      } on PiholeException catch (e) {
        expect(e.message.contains('unexpected plaintext response'), isTrue);
      }
    });
  });

  group('blacklist', () {
    group('fetchBlacklist', () {
      test('returns Blacklist on successful response', () async {
        dio.httpClientAdapter =
            MockAdapter.string(json.encode(mockBlacklist.toJson()));
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

//    group('fetchQueries', () {
//      test('returns list of Queries on successful fetch', () async {
//        dio.httpClientAdapter =
//            MockAdapter.string('adding new.com to whitelist...');
//        expect(client.fetchQueries(), completion(mockQueries));
//      });
//    });
  });
}
