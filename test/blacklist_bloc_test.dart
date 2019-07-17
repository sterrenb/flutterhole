import 'package:flutterhole/bloc/blacklist/bloc.dart';
import 'package:flutterhole/model/blacklist.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockBlacklistRepository extends Mock implements BlacklistRepository {
  Blacklist cache;
}

main() {
  MockBlacklistRepository blacklistRepository;
  BlacklistBloc blacklistBloc;

  setUp(() {
    blacklistRepository = MockBlacklistRepository();
    blacklistBloc = BlacklistBloc(blacklistRepository);
  });

  test('has a correct initialState', () {
    expect(blacklistBloc.initialState, BlacklistStateEmpty());
  });

  group('FetchBlacklist', () {
    test(
        'emits [BlacklistStateEmpty, BlacklistStateLoading, BlacklistStateSuccess] when blacklist repository returns Blacklist',
        () {
      final Blacklist blacklist = Blacklist();

      when(blacklistRepository.getBlacklist())
          .thenAnswer((_) => Future.value(blacklist));

      expectLater(
          blacklistBloc.state,
          emitsInOrder([
            BlacklistStateEmpty(),
            BlacklistStateLoading(),
            BlacklistStateSuccess(blacklist),
          ]));

      blacklistBloc.dispatch(FetchBlacklist());
    });

    test(
        'emits [BlacklistStateEmpty, BlacklistStateLoading, BlacklistStateError] when blacklist repository throws PiholeException',
        () {
      when(blacklistRepository.getBlacklist()).thenThrow(PiholeException());

      expectLater(
          blacklistBloc.state,
          emitsInOrder([
            BlacklistStateEmpty(),
            BlacklistStateLoading(),
            BlacklistStateError(e: PiholeException()),
          ]));

      blacklistBloc.dispatch(FetchBlacklist());
    });
  });

  group('AddToBlacklist', () {
    setUp(() {
      blacklistRepository.cache = Blacklist();
    });
    test(
        'emits [BlacklistStateEmpty, BlacklistStateLoading, BlacklistStateSuccess] when blacklist repository adds succesfully',
        () {
      final BlacklistItem item =
          BlacklistItem(entry: 'new', type: BlacklistType.Exact);
      final Blacklist blacklist = Blacklist();
      when(blacklistRepository.addToBlacklist(item))
          .thenAnswer((_) => Future.value(blacklist));

      expectLater(
          blacklistBloc.state,
          emitsInOrder([
            BlacklistStateEmpty(),
            BlacklistStateLoading(cache: blacklistRepository.cache),
            BlacklistStateSuccess(blacklist),
          ]));

      blacklistBloc.dispatch(AddToBlacklist(item));
    });

    test(
        'emits [BlacklistStateEmpty, BlacklistStateLoading, BlacklistStateError] when blacklist repository add fails',
        () {
      final BlacklistItem item =
          BlacklistItem(entry: 'new', type: BlacklistType.Exact);
      when(blacklistRepository.addToBlacklist(item))
          .thenThrow(PiholeException());

      expectLater(
          blacklistBloc.state,
          emitsInOrder([
            BlacklistStateEmpty(),
            BlacklistStateLoading(cache: blacklistRepository.cache),
            BlacklistStateError(e: PiholeException()),
          ]));

      blacklistBloc.dispatch(AddToBlacklist(item));
    });
  });

  group('RemoveFromBlacklist', () {
    test(
        'emits [BlacklistStateEmpty, BlacklistStateLoading, BlacklistStateSuccess] when blacklist repository removes succesfully',
        () {
      final BlacklistItem item =
          BlacklistItem(entry: 'new', type: BlacklistType.Exact);
      blacklistRepository.cache = Blacklist();
      when(blacklistRepository.removeFromBlacklist(item))
          .thenAnswer((_) => Future.value(Blacklist()));

      expectLater(
          blacklistBloc.state,
          emitsInOrder([
            BlacklistStateEmpty(),
            BlacklistStateLoading(cache: blacklistRepository.cache),
            BlacklistStateSuccess(Blacklist()),
          ]));

      blacklistBloc.dispatch(RemoveFromBlacklist(item));
    });

    test(
        'emits [BlacklistStateEmpty, BlacklistStateLoading, BlacklistStateError] when blacklist repository add fails',
        () {
      final BlacklistItem item =
          BlacklistItem(entry: 'new', type: BlacklistType.Exact);
      when(blacklistRepository.removeFromBlacklist(item))
          .thenThrow(PiholeException());

      expectLater(
          blacklistBloc.state,
          emitsInOrder([
            BlacklistStateEmpty(),
            BlacklistStateLoading(),
            BlacklistStateError(e: PiholeException()),
          ]));

      blacklistBloc.dispatch(RemoveFromBlacklist(item));
    });
  });
}
