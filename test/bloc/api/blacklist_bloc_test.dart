import 'dart:async';

import 'package:flutterhole/bloc/api/blacklist.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/blacklist.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../mock.dart';

class MockBlacklistRepository extends Mock implements BlacklistRepository {
  @override
  Blacklist cache;
}

main() {
  group('bloc', () {
    MockBlacklistRepository blacklistRepository;
    BlacklistBloc blacklistBloc;

    setUp(() {
      blacklistRepository = MockBlacklistRepository();
      blacklistBloc = BlacklistBloc(blacklistRepository);
    });

    test('has a correct initialState', () {
      expect(blacklistBloc.initialState, BlocStateEmpty<Blacklist>());
    });

    group('fetch', () {
      test(
          'emits [BlocStateEmpty<Blacklist>, BlocStateLoading<Blacklist>, BlocStateSuccess<Blacklist>] when blacklist repository returns Blacklist',
              () {
            final Blacklist blacklist = Blacklist();

            when(blacklistRepository.get())
                .thenAnswer((_) => Future.value(blacklist));

            expectLater(
                blacklistBloc.state,
                emitsInOrder([
                  BlocStateEmpty<Blacklist>(),
                  BlocStateLoading<Blacklist>(),
                  BlocStateSuccess<Blacklist>(blacklist),
                ]));

            blacklistBloc.dispatch(Fetch());
          });

      test(
          'emits [BlocStateEmpty<Blacklist>, BlocStateLoading<Blacklist>, BlocStateError<Blacklist>] when blacklist repository throws PiholeException',
              () {
            when(blacklistRepository.get()).thenThrow(PiholeException());

            expectLater(
                blacklistBloc.state,
                emitsInOrder([
                  BlocStateEmpty<Blacklist>(),
                  BlocStateLoading<Blacklist>(),
                  BlocStateError<Blacklist>(PiholeException()),
                ]));

            blacklistBloc.dispatch(Fetch());
          });
    });

    group('add', () {
      setUp(() {
        blacklistRepository.cache = Blacklist();
      });
      test(
          'emits [BlocStateEmpty<Blacklist>, BlocStateLoading<Blacklist>, BlocStateSuccess<Blacklist>] when blacklist repository adds succesfully',
              () {
            final BlacklistItem item =
            BlacklistItem(entry: 'new', type: BlacklistType.Exact);
            final Blacklist blacklist = Blacklist();
            when(blacklistRepository.add(item))
                .thenAnswer((_) => Future.value(blacklist));

            expectLater(
                blacklistBloc.state,
                emitsInOrder([
                  BlocStateEmpty<Blacklist>(),
                  BlocStateLoading<Blacklist>(),
                  BlocStateSuccess<Blacklist>(blacklist),
                ]));

            blacklistBloc.dispatch(Add(item));
          });

      test(
          'emits [BlocStateEmpty<Blacklist>, BlocStateLoading<Blacklist>, BlocStateError<Blacklist>] when blacklist repository add fails',
              () {
            final BlacklistItem item =
            BlacklistItem(entry: 'new', type: BlacklistType.Exact);
            when(blacklistRepository.add(item)).thenThrow(PiholeException());

            expectLater(
                blacklistBloc.state,
                emitsInOrder([
                  BlocStateEmpty<Blacklist>(),
                  BlocStateLoading<Blacklist>(),
                  BlocStateError<Blacklist>(PiholeException()),
                ]));

            blacklistBloc.dispatch(Add(item));
          });
    });

    group('remove', () {
      test(
          'emits [BlocStateEmpty<Blacklist>, BlocStateLoading<Blacklist>, BlocStateSuccess<Blacklist>] when blacklist repository removes succesfully',
              () {
            final BlacklistItem item =
            BlacklistItem(entry: 'new', type: BlacklistType.Exact);
            blacklistRepository.cache = Blacklist();
            when(blacklistRepository.remove(item))
                .thenAnswer((_) => Future.value(Blacklist()));

            expectLater(
                blacklistBloc.state,
                emitsInOrder([
                  BlocStateEmpty<Blacklist>(),
                  BlocStateLoading<Blacklist>(),
                  BlocStateSuccess<Blacklist>(Blacklist()),
                ]));

            blacklistBloc.dispatch(Remove(item));
          });

      test(
          'emits [BlocStateEmpty<Blacklist>, BlocStateLoading<Blacklist>, BlocStateError<Blacklist>] when blacklist repository add fails',
              () {
            final BlacklistItem item =
            BlacklistItem(entry: 'new', type: BlacklistType.Exact);
            when(blacklistRepository.remove(item)).thenThrow(PiholeException());

            expectLater(
                blacklistBloc.state,
                emitsInOrder([
                  BlocStateEmpty<Blacklist>(),
                  BlocStateLoading<Blacklist>(),
                  BlocStateError<Blacklist>(PiholeException()),
                ]));

            blacklistBloc.dispatch(Remove(item));
          });
    });

    group('edit', () {
      final BlacklistItem original = BlacklistItem.exact(entry: 'a.com');
      final BlacklistItem update = BlacklistItem.exact(entry: 'b.com');
      setUp(() {
        blacklistRepository.cache = Blacklist(exact: [original]);
      });
      test(
          'emits [BlocStateEmpty<Blacklist>, BlocStateLoading<Blacklist>, BlocStateSuccess<Blacklist>] when blacklist repository edits succesfully',
              () {
            final Blacklist blacklistNew = Blacklist(exact: [update]);
            when(blacklistRepository.edit(original, update))
                .thenAnswer((_) => Future.value(blacklistNew));

            expectLater(
                blacklistBloc.state,
                emitsInOrder([
                  BlocStateEmpty<Blacklist>(),
                  BlocStateLoading<Blacklist>(),
                  BlocStateSuccess<Blacklist>(blacklistNew),
                ]));

            blacklistBloc.dispatch(Edit(original, update));
          });

      test(
          'emits [BlocStateEmpty<Blacklist>, BlocStateLoading<Blacklist>, BlocStateError<Blacklist>] when blacklist repository edit fails',
              () {
            when(blacklistRepository.edit(original, update))
                .thenThrow(PiholeException());

            expectLater(
                blacklistBloc.state,
                emitsInOrder([
                  BlocStateEmpty<Blacklist>(),
                  BlocStateLoading<Blacklist>(),
                  BlocStateError<Blacklist>(PiholeException()),
                ]));

            blacklistBloc.dispatch(Edit(original, update));
          });
    });
  });

  group('repository', () {
    MockPiholeClient client;
    BlacklistRepository blacklistRepository;

    setUp(() {
      client = MockPiholeClient();
      blacklistRepository =
          BlacklistRepository(client, initialValue: mockBlacklist);
    });

    group('constructor', () {
      test('initially default', () {
        blacklistRepository = BlacklistRepository(client);
        expect(blacklistRepository.cache, Blacklist());
      });
      test('initial test cache is mocked', () {
        expect(blacklistRepository.cache, mockBlacklist);
      });
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
        final completer = Completer<void>()
          ..complete();
        return completer.future;
      });

      expect(blacklistRepository.add(item), completion(list));
    });

    test('removeFromBlacklist', () {
      final BlacklistItem original = mockBlacklist.exact.first;
      final Blacklist list = Blacklist.withoutItem(mockBlacklist, original);

      when(client.removeFromBlacklist(original)).thenAnswer((_) {
        final completer = Completer<void>()
          ..complete();
        return completer.future;
      });

      assert(original != null);
      expect(blacklistRepository.remove(original), completion(list));
    });

    test('editOnBlacklist', () {
      final BlacklistItem original = mockBlacklist.exact.first;
      final BlacklistItem update = BlacklistItem.exact(entry: 'test');
      final Blacklist list = Blacklist.withItem(
          Blacklist.withoutItem(mockBlacklist, original), update);

      when(client.editOnBlacklist(original, update)).thenAnswer((_) {
        final completer = Completer<void>()
          ..complete();
        return completer.future;
      });

      assert(original != null);
      expect(blacklistRepository.edit(original, update), completion(list));
    });
  });
}
