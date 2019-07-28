import 'dart:async';

import 'package:flutterhole/bloc/api/blacklist.dart';
import 'package:flutterhole/bloc/api/forward_destinations.dart';
import 'package:flutterhole/bloc/api/query.dart';
import 'package:flutterhole/bloc/api/query_types.dart';
import 'package:flutterhole/bloc/api/status.dart';
import 'package:flutterhole/bloc/api/summary.dart';
import 'package:flutterhole/bloc/api/top_items.dart';
import 'package:flutterhole/bloc/api/top_sources.dart';
import 'package:flutterhole/bloc/api/whitelist.dart';
import 'package:flutterhole/model/api/blacklist.dart';
import 'package:flutterhole/model/api/whitelist.dart';
import 'package:flutterhole/service/pihole_client.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../mock.dart';

class MockPiholeClient extends Mock implements PiholeClient {}

main() {
  MockPiholeClient client;
  setUp(() {
    client = MockPiholeClient();
  });

  group('SummaryRepository', () {
    SummaryRepository summaryRepository;

    setUp(() {
      summaryRepository = SummaryRepository(client);
    });

    test('get', () {
      when(client.fetchSummary()).thenAnswer((_) => Future.value(mockSummary));
      expect(summaryRepository.get(), completion(mockSummary));
    });
  });

  group('ForwardDestinationsRepository', () {
    ForwardDestinationsRepository forwardDestinationsRepository;

    setUp(() {
      forwardDestinationsRepository = ForwardDestinationsRepository(client);
    });

    test('getForwardDestinations', () {
      when(client.fetchForwardDestinations())
          .thenAnswer((_) => Future.value(mockForwardDestinations));
      expect(forwardDestinationsRepository.get(),
          completion(mockForwardDestinations));
    });
  });

  group('QueryTypesRepository', () {
    QueryTypesRepository queryTypesRepository;

    setUp(() {
      queryTypesRepository = QueryTypesRepository(client);
    });

    test('getQueryTypes', () {
      when(client.fetchQueryTypes())
          .thenAnswer((_) => Future.value(mockQueryTypes));
      expect(queryTypesRepository.get(), completion(mockQueryTypes));
    });
  });

  group('TopItemsRepository', () {
    TopItemsRepository topItemsRepository;

    setUp(() {
      topItemsRepository = TopItemsRepository(client);
    });

    test('getTopItems', () {
      when(client.fetchTopItems())
          .thenAnswer((_) => Future.value(mockTopItems));
      expect(topItemsRepository.get(), completion(mockTopItems));
    });
  });

  group('QueryRepository', () {
    QueryRepository queryRepository;

    setUp(() {
      queryRepository = QueryRepository(client);
    });

//    test('initial cache is empty', () {
//      expect(queryRepository.cache, []);
//    });

    test('getQueries', () {
      when(client.fetchQueries()).thenAnswer((_) => Future.value(mockQueries));

      expect(queryRepository.get(), completion(mockQueries));
    });

    test('getQueriesForClient', () {
      when(client.fetchQueriesForClient('client'))
          .thenAnswer((_) => Future.value(mockQueries));
      expect(queryRepository.getForClient('client'), completion(mockQueries));
    });
  });

  group('TopSourcesRepository', () {
    TopSourcesRepository topSourcesRepository;

    setUp(() {
      topSourcesRepository = TopSourcesRepository(client);
    });

    test('getTopSources', () {
      when(client.fetchTopSources()).thenAnswer((_) =>
          Future.value(mockTopSources));
      expect(topSourcesRepository.get(), completion(mockTopSources));
    });
  });

  group('BlacklistRepository', () {
    BlacklistRepository blacklistRepository;

    setUp(() {
      blacklistRepository =
          BlacklistRepository(client, initialValue: mockBlacklist);
    });

    test('initial cache is mocked', () {
      expect(blacklistRepository.cache, mockBlacklist);
    });

    test('getBlacklist', () {
      when(client.fetchBlacklist())
          .thenAnswer((_) => Future.value(mockBlacklist));

      expect(blacklistRepository.get(), completion(mockBlacklist));
    });

    test('addToBlacklist', () {
      final BlacklistItem item = BlacklistItem.exact(entry: 'test');
      final Blacklist list = Blacklist.withItem(mockBlacklist, item);

      when(client.addToBlacklist(item)).thenAnswer((_) {
        final completer = Completer<void>()..complete();
        return completer.future;
      });

      expect(blacklistRepository.add(item), completion(list));
    });

    test('removeFromBlacklist', () {
      final BlacklistItem original = mockBlacklist.exact.first;
      final Blacklist list = Blacklist.withoutItem(mockBlacklist, original);

      when(client.removeFromBlacklist(original)).thenAnswer((_) {
        final completer = Completer<void>()..complete();
        return completer.future;
      });

      assert(original != null);
      expect(
          blacklistRepository.remove(original), completion(list));
    });

    test('editOnBlacklist', () {
      final BlacklistItem original = mockBlacklist.exact.first;
      final BlacklistItem update = BlacklistItem.exact(entry: 'test');
      final Blacklist list = Blacklist.withItem(
          Blacklist.withoutItem(mockBlacklist, original), update);

      when(client.editOnBlacklist(original, update)).thenAnswer((_) {
        final completer = Completer<void>()..complete();
        return completer.future;
      });

      assert(original != null);
      expect(blacklistRepository.remove(update), completion(list));
    });
  });

  group('WhitelistRepository', () {
    WhitelistRepository whitelistRepository;

    setUp(() {
      whitelistRepository =
          WhitelistRepository(client, initialValue: mockWhitelist);
    });

    test('initial cache is mocked', () {
      expect(whitelistRepository.cache, mockWhitelist);
    });

    test('getWhitelist', () {
      when(client.fetchWhitelist())
          .thenAnswer((_) => Future.value(mockWhitelist));

      expect(whitelistRepository.get(), completion(mockWhitelist));
    });

    test('addToWhitelist', () {
      final String domain = 'test';
      final Whitelist list = Whitelist.withItem(mockWhitelist, domain);

      when(client.addToWhitelist(domain)).thenAnswer((_) {
        final completer = Completer<void>()..complete();
        return completer.future;
      });

      expect(whitelistRepository.addToWhitelist(domain), completion(list));
    });

    test('removeFromWhitelist', () {
      final String domain = mockWhitelist.list.first;
      final Whitelist list = Whitelist.withoutItem(mockWhitelist, domain);

      when(client.removeFromWhitelist(domain)).thenAnswer((_) {
        final completer = Completer<void>()..complete();
        return completer.future;
      });

      expect(whitelistRepository.removeFromWhitelist(domain), completion(list));
    });

    test('editOnWhitelist', () {
      final String original = mockWhitelist.list.first;
      final String update = 'test';
      final Whitelist list = Whitelist.withoutItem(
          Whitelist.withItem(mockWhitelist, update), original);

      when(client.editOnWhitelist(original, update)).thenAnswer((_) {
        final completer = Completer<void>()..complete();
        return completer.future;
      });

      assert(original != null);
      expect(whitelistRepository.editOnWhitelist(original, update),
          completion(list));
    });
  });

  group('StatusRepository', () {
    StatusRepository statusRepository;

    setUp(() {
      statusRepository = StatusRepository(client);
    });

    test('initial stopwatch is stopped', () {
      expect(statusRepository.stopwatch.isRunning, isFalse);
    });

    test('getStatus', () {
      when(client.fetchStatus())
          .thenAnswer((_) => Future.value(mockStatusEnabled));

      expect(statusRepository.get(), completion(mockStatusEnabled));
    });

    test('enable', () {
      when(client.enable()).thenAnswer((_) => Future.value(mockStatusEnabled));

      expect(statusRepository.enable(), completion(mockStatusEnabled));
    });

    test('disable', () {
      when(client.disable())
          .thenAnswer((_) => Future.value(mockStatusDisabled));

      expect(statusRepository.disable(), completion(mockStatusDisabled));
    });

    test('sleep', () async {
      final duration = Duration(seconds: 5);

      when(client.disable(duration))
          .thenAnswer((_) => Future.value(mockStatusDisabled));

      final status = await statusRepository.sleep(duration, () {});

      expect(status, mockStatusDisabled);
      expect(statusRepository.stopwatch.isRunning, isTrue);
      expect(statusRepository.elapsed.inMicroseconds, greaterThan(0));

      expect(statusRepository.sleep(duration, () {}),
          completion(mockStatusDisabled));
    });

    test('cancelSleep', () {
      statusRepository.cancelSleep();
      expect(statusRepository.stopwatch.isRunning, isFalse);
      expect(statusRepository.elapsed.inMicroseconds, equals(0));
    });

    test('cancelSleep while sleeping', () {
      statusRepository.sleep(Duration(seconds: 5), () {});
      statusRepository.cancelSleep();
      expect(statusRepository.stopwatch.isRunning, isFalse);
      expect(statusRepository.elapsed.inMicroseconds, equals(0));
    });
  });
}
