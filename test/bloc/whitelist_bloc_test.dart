import 'package:flutterhole/bloc/whitelist/bloc.dart';
import 'package:flutterhole/model/whitelist.dart';
import 'package:flutterhole/service/pihole_exception.dart';
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
      whitelistRepository.cache = Whitelist(['new']);
    });
    test(
        'emits [WhitelistStateEmpty, WhitelistStateLoading, WhitelistStateSuccess] when whitelist repository adds succesfully',
        () {
          final Whitelist whitelist = Whitelist(['new']);
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

  group('EditOnWhitelist', () {
    setUp(() {
      whitelistRepository.cache = Whitelist(['old']);
    });
    test(
        'emits [WhitelistStateEmpty, WhitelistStateLoading, WhitelistStateSuccess] when whitelist repository edits succesfully',
            () {
          final Whitelist whitelistNew = Whitelist(['new']);
          when(whitelistRepository.editOnWhitelist('old', 'new'))
              .thenAnswer((_) => Future.value(whitelistNew));

          expectLater(
              whitelistBloc.state,
              emitsInOrder([
                WhitelistStateEmpty(),
                WhitelistStateLoading(cache: whitelistRepository.cache),
                WhitelistStateSuccess(whitelistNew),
              ]));

          whitelistBloc.dispatch(EditOnWhitelist('old', 'new'));
        });

    test(
        'emits [WhitelistStateEmpty, WhitelistStateLoading, WhitelistStateError] when whitelist repository edit fails',
            () {
          when(whitelistRepository.editOnWhitelist('old', 'new'))
              .thenThrow(PiholeException());

          expectLater(
              whitelistBloc.state,
              emitsInOrder([
                WhitelistStateEmpty(),
                WhitelistStateLoading(cache: whitelistRepository.cache),
                WhitelistStateError(e: PiholeException()),
              ]));

          whitelistBloc.dispatch(EditOnWhitelist('old', 'new'));
        });
  });
}
