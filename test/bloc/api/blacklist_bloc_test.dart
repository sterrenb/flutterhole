import 'package:flutterhole/bloc/api/blacklist.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/blacklist.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

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

  });
}
