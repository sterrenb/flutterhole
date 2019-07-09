import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutterhole_again/model/model.dart';
import 'package:flutterhole_again/model/pihole.dart';
import 'package:flutterhole_again/service/local_storage.dart';
import 'package:flutterhole_again/service/pihole_client.dart';
import 'package:flutterhole_again/service/pihole_exception.dart';
import "package:test/test.dart";
import 'package:mockito/mockito.dart';

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

class MockAdapter extends HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<List<int>> requestStream, Future cancelFuture) async {
    if (options.uri.queryParameters.containsKey('empty')) {
      return ResponseBody.fromString('[]', 200);
    }
    if (options.uri.queryParameters.containsKey('not authorized')) {
      return ResponseBody.fromString('Not authorized!', 200);
    }
    if (options.uri.queryParameters
        .containsKey('successful response enabled')) {
      return ResponseBody.fromString(statusToJson(mockStatusEnabled), 200);
    }
    if (options.uri.queryParameters
        .containsKey('successful response disabled')) {
      return ResponseBody.fromString(statusToJson(mockStatusDisabled), 200);
    }
    if (options.uri.queryParameters.containsKey('successful summary')) {
      return ResponseBody.fromString(mockSummary.toJson(), 200);
    }
    if (options.uri.queryParameters.containsKey('successful whitelist')) {
      return ResponseBody.fromString(mockWhitelist.toJson(), 200);
    }
    if (options.uri.queryParameters.containsKey('successful blacklist')) {
      return ResponseBody.fromString(mockBlacklist.toJson(), 200);
    }
    if (options.uri.queryParameters.containsKey('duplicate blacklist')) {
      return ResponseBody.fromString('already exists', 200);
    }
    if (options.uri.queryParameters.containsKey('invalid blacklist')) {
      return ResponseBody.fromString('not a valid domain', 200);
    }
    if (options.uri.queryParameters.containsKey('successful whitelist add')) {
      return ResponseBody.fromString('[i] Adding new.com to whitelist...', 200);
    }
    if (options.uri.queryParameters.containsKey('duplicate whitelist')) {
      return ResponseBody.fromString("""
      [i] abc.cm already exists in whitelist, no need to add!
      [i] abc.cm does not exist in blacklist, no need to remove!
      """, 200);
    }

    throw Exception('no valid debug key in request');
  }
}

void main() {
  PiholeClient client;

  setUp(() async {
    final dio = Dio(BaseOptions(
      baseUrl: 'http://pi.hole/admin/api.php',
    ));
    dio.httpClientAdapter = MockAdapter();
    final localStorage = MockLocalStorage();
    client = PiholeClient(dio: dio, localStorage: localStorage);

    when(localStorage.active()).thenReturn(Pihole());
  });

  group('fetchStatus', () {
    test('returns true on successful response enabled', () async {
      client.dio.options.queryParameters = {'successful response enabled': ''};
      expect(client.fetchEnabled(), completes);
    });

    test('throws PiholeException on empty response', () async {
      client.dio.options.queryParameters = {'empty': ''};
      try {
        await client.fetchEnabled();
        fail('exception not thrown');
      } catch (e) {
        expect(e, TypeMatcher<PiholeException>());
      }
    });

    test('throws PiholeException on unresolved hostname', () async {
      client.dio.options.baseUrl = 'fake.com';
      try {
        await client.fetchEnabled();
        fail('exception not thrown');
      } catch (e) {
        expect(e, TypeMatcher<PiholeException>());
      }
    });

    test('throws PiholeException on not authorized response', () async {
      client.dio.options.queryParameters = {'not authorized': ''};
      try {
        await client.fetchEnabled();
        fail('exception not thrown');
      } catch (e) {
        expect(e, TypeMatcher<PiholeException>());
      }
    });
  });

  group('enable', () {
    test('returns on successful response enabled', () async {
      client.dio.options.queryParameters = {'successful response enabled': ''};
      expect(client.enable(), completes);
    });

    test('throws PiholeException on disabled response', () async {
      client.dio.options.queryParameters = {'successful response disabled': ''};
      try {
        await client.enable();
        fail('exception not thrown');
      } catch (e) {
        expect(e, TypeMatcher<PiholeException>());
      }
    });
  });

  group('disable', () {
    test('returns on successful response disabled', () async {
      client.dio.options.queryParameters = {'successful response disabled': ''};
      expect(client.disable(), completes);
    });

    test('throws PiholeException on enabled response', () async {
      client.dio.options.queryParameters = {'successful response enabled': ''};
      try {
        await client.disable();
        fail('exception not thrown');
      } catch (e) {
        expect(e, TypeMatcher<PiholeException>());
      }
    });
  });

  test('fetchSummary', () async {
    client.dio.options.queryParameters = {'successful summary': ''};
    final summary = await client.fetchSummary();
    expect(summary, mockSummary);
  });

  group('blacklist', () {
    group('blacklist add', () {
      test('returns on successful exact add', () async {
        client.dio.options.queryParameters = {'successful blacklist': ''};
        expect(
            client.addToBlacklist(
                BlacklistItem(entry: 'example.com', type: BlacklistType.Exact)),
            completes);
      });

      test('returns on successful wildcard add', () async {
        client.dio.options.queryParameters = {'successful blacklist': ''};
        expect(
            client.addToBlacklist(BlacklistItem(
                entry: 'wildcard.com', type: BlacklistType.Wildcard)),
            completes);
      });

      test('returns on successful regex add', () async {
        client.dio.options.queryParameters = {'successful blacklist': ''};
        expect(
            client.addToBlacklist(
                BlacklistItem(entry: 'regex', type: BlacklistType.Regex)),
            completes);
      });

      test('throws on duplicate add', () async {
        client.dio.options.queryParameters = {'duplicate blacklist': ''};
        try {
          await client.addToBlacklist(
              BlacklistItem(entry: 'example.com', type: BlacklistType.Regex));
          fail('exception not thrown');
        } catch (e) {
          expect(e, TypeMatcher<PiholeException>());
        }
      });

      test('throws on invalid add', () async {
        client.dio.options.queryParameters = {'invalid blacklist': ''};
        try {
          await client.addToBlacklist(
              BlacklistItem(entry: '', type: BlacklistType.Regex));
          fail('exception not thrown');
        } catch (e) {
          expect(e, TypeMatcher<PiholeException>());
        }
      });

      test('returns on successful blacklist edit', () async {
        client.dio.options.queryParameters = {'successful blacklist': ''};
        expect(
            client.editOnBlacklist(
                BlacklistItem(
                    entry: 'wildcard.com', type: BlacklistType.Wildcard),
                BlacklistItem(
                    entry: 'wildcard.edited.com',
                    type: BlacklistType.Wildcard)),
            completes);
      });

      test('returns on successful exact remove', () async {
        client.dio.options.queryParameters = {'successful blacklist': ''};
        expect(
            client.removeFromBlacklist(
                BlacklistItem(entry: 'example.com', type: BlacklistType.Exact)),
            completes);
      });
    });
  });

  group('whitelist', () {
    test('fetchWhitelist', () async {
      client.dio.options.queryParameters = {'successful whitelist': ''};
      final whitelist = await client.fetchWhitelist();
      expect(whitelist, mockWhitelist);
    });

    test('addToWhitelist succesful add', () async {
      client.dio.options.queryParameters = {'successful whitelist add': ''};
      expect(client.addToWhitelist('new.com'), completes);
    });

    test('throws PiholeException on duplicate addToWhitelist', () async {
      client.dio.options.queryParameters = {
        'duplicate whitelist': '',
      };
      try {
        await client.addToWhitelist('new.com');
        fail('exception not thrown');
      } catch (e) {
        expect(e, TypeMatcher<PiholeException>());
      }
    });

    test('throws PiholeException on unauthorized addToWhitelist', () async {
      client.dio.options.queryParameters = {'not authorized': ''};
      try {
        await client.addToWhitelist('new.com');
        fail('exception not thrown');
      } catch (e) {
        expect(e, TypeMatcher<PiholeException>());
      }
    });

    test('throws PiholeException on unauthorized removeFromWhitelist',
            () async {
          client.dio.options.queryParameters = {'not authorized': ''};
          try {
            await client.removeFromWhitelist('new.com');
            fail('exception not thrown');
          } catch (e) {
            expect(e, TypeMatcher<PiholeException>());
          }
        });

    test('editOnWhitelist returns', () async {
      client.dio.options.queryParameters = {'successful whitelist add': ''};
      expect(client.editOnWhitelist('original.com', 'new.com'), completes);
    });
  });
}
