import 'package:flutterhole_again/bloc/whitelist/whitelist_bloc.dart';
import 'package:flutterhole_again/bloc/whitelist/whitelist_event.dart';
import 'package:flutterhole_again/bloc/whitelist/whitelist_state.dart';
import 'package:flutterhole_again/model/whitelist.dart';
import 'package:flutterhole_again/repository/whitelist_repository.dart';
import 'package:flutterhole_again/service/pihole_exception.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockWhitelistRepository extends Mock implements WhitelistRepository {
  Whitelist cache;
}

main() {
  MockWhitelistRepository whitelistRepository;
  WhitelistBloc whitelistBloc;

  setUp(() {
    whitelistRepository = MockWhitelistRepository();
    whitelistBloc = WhitelistBloc(whitelistRepository);
  });

  test('has a correct initialState', () {
    expect(whitelistBloc.initialState, WhitelistStateEmpty());
  });

  group('FetchWhitelist', () {
    test(
        'emits [WhitelistStateEmpty, WhitelistStateLoading, WhitelistStateSuccess] when whitelist repository returns Whitelist',
        () {
      final Whitelist whitelist = Whitelist();

      when(whitelistRepository.getWhitelist())
          .thenAnswer((_) => Future.value(whitelist));

      expectLater(
          whitelistBloc.state,
          emitsInOrder([
            WhitelistStateEmpty(),
            WhitelistStateLoading(),
            WhitelistStateSuccess(whitelist),
          ]));

      whitelistBloc.dispatch(FetchWhitelist());
    });

    test(
        'emits [WhitelistStateEmpty, WhitelistStateLoading, WhitelistStateError] when whitelist repository throws PiholeException',
        () {
      when(whitelistRepository.getWhitelist()).thenThrow(PiholeException());

      expectLater(
          whitelistBloc.state,
          emitsInOrder([
            WhitelistStateEmpty(),
            WhitelistStateLoading(),
            WhitelistStateError(e: PiholeException()),
          ]));

      whitelistBloc.dispatch(FetchWhitelist());
    });
  });

  group('AddToWhitelist', () {
    setUp(() {
      whitelistRepository.cache = Whitelist(list: ['new']);
    });
    test(
        'emits [WhitelistStateEmpty, WhitelistStateLoading, WhitelistStateSuccess] when whitelist repository adds succesfully',
        () {
      final Whitelist whitelist = Whitelist(list: ['new']);
      when(whitelistRepository.addToWhitelist('new'))
          .thenAnswer((_) => Future.value(whitelist));

      expectLater(
          whitelistBloc.state,
          emitsInOrder([
            WhitelistStateEmpty(),
            WhitelistStateLoading(cache: whitelistRepository.cache),
            WhitelistStateSuccess(whitelist),
          ]));

      whitelistBloc.dispatch(AddToWhitelist('new'));
    });

    test(
        'emits [WhitelistStateEmpty, WhitelistStateLoading, WhitelistStateError] when whitelist repository add fails',
        () {
      when(whitelistRepository.addToWhitelist('new'))
          .thenThrow(PiholeException());

      expectLater(
          whitelistBloc.state,
          emitsInOrder([
            WhitelistStateEmpty(),
            WhitelistStateLoading(cache: whitelistRepository.cache),
            WhitelistStateError(e: PiholeException()),
          ]));

      whitelistBloc.dispatch(AddToWhitelist('new'));
    });
  });

  group('RemoveFromWhitelist', () {
    test(
        'emits [WhitelistStateEmpty, WhitelistStateLoading, WhitelistStateSuccess] when whitelist repository removes succesfully',
        () {
      whitelistRepository.cache = Whitelist();
      when(whitelistRepository.removeFromWhitelist('remove'))
          .thenAnswer((_) => Future.value(Whitelist()));

      expectLater(
          whitelistBloc.state,
          emitsInOrder([
            WhitelistStateEmpty(),
            WhitelistStateLoading(cache: whitelistRepository.cache),
            WhitelistStateSuccess(Whitelist()),
          ]));

      whitelistBloc.dispatch(RemoveFromWhitelist('remove'));
    });

    test(
        'emits [WhitelistStateEmpty, WhitelistStateLoading, WhitelistStateError] when whitelist repository add fails',
        () {
      when(whitelistRepository.removeFromWhitelist('new'))
          .thenThrow(PiholeException());

      expectLater(
          whitelistBloc.state,
          emitsInOrder([
            WhitelistStateEmpty(),
            WhitelistStateLoading(),
            WhitelistStateError(e: PiholeException()),
          ]));

      whitelistBloc.dispatch(RemoveFromWhitelist('new'));
    });
  });
}
