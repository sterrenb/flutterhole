import 'package:flutterhole/bloc/api/blacklist/bloc.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
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
    expect(blacklistBloc.initialState, BlocStateEmpty<Blacklist>());
  });

  group('FetchBlacklist', () {
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

  group('AddToBlacklist', () {
    setUp(() {
      blacklistRepository.cache = Blacklist();
    });
    test(
        'emits [BlocStateEmpty<Blacklist>, BlocStateLoading<Blacklist>, BlocStateSuccess<Blacklist>] when blacklist repository adds succesfully',
        () {
      final BlacklistItem item =
          BlacklistItem(entry: 'new', type: BlacklistType.Exact);
      final Blacklist blacklist = Blacklist();
      when(blacklistRepository.addToBlacklist(item))
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
      when(blacklistRepository.addToBlacklist(item))
          .thenThrow(PiholeException());

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

  group('RemoveFromBlacklist', () {
    test(
        'emits [BlocStateEmpty<Blacklist>, BlocStateLoading<Blacklist>, BlocStateSuccess<Blacklist>] when blacklist repository removes succesfully',
        () {
      final BlacklistItem item =
          BlacklistItem(entry: 'new', type: BlacklistType.Exact);
      blacklistRepository.cache = Blacklist();
      when(blacklistRepository.removeFromBlacklist(item))
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
      when(blacklistRepository.removeFromBlacklist(item))
          .thenThrow(PiholeException());

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
}
