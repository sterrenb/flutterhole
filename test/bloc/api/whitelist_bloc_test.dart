import 'package:flutterhole/bloc/api/whitelist.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/whitelist.dart';
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
    expect(whitelistBloc.initialState, BlocStateEmpty<Whitelist>());
  });

  group('Fetch', () {
    test(
        'emits [BlocStateEmpty<Whitelist>, BlocStateLoading<Whitelist>, BlocStateSuccess<Whitelist>] when whitelist repository returns Whitelist',
        () {
      final Whitelist whitelist = Whitelist();

      when(whitelistRepository.get())
          .thenAnswer((_) => Future.value(whitelist));

      expectLater(
          whitelistBloc.state,
          emitsInOrder([
            BlocStateEmpty<Whitelist>(),
            BlocStateLoading<Whitelist>(),
            BlocStateSuccess<Whitelist>(whitelist),
          ]));

      whitelistBloc.dispatch(Fetch());
    });

    test(
        'emits [BlocStateEmpty<Whitelist>, BlocStateLoading<Whitelist>, BlocStateError<Whitelist>] when whitelist repository throws PiholeException',
        () {
          when(whitelistRepository.get()).thenThrow(PiholeException());

      expectLater(
          whitelistBloc.state,
          emitsInOrder([
            BlocStateEmpty<Whitelist>(),
            BlocStateLoading<Whitelist>(),
            BlocStateError<Whitelist>(PiholeException()),
          ]));

          whitelistBloc.dispatch(Fetch());
    });
  });

  group('Add', () {
    setUp(() {
      whitelistRepository.cache = Whitelist(['new']);
    });
    test(
        'emits [BlocStateEmpty<Whitelist>, BlocStateLoading<Whitelist>, BlocStateSuccess<Whitelist>] when whitelist repository adds succesfully',
        () {
          final Whitelist whitelist = Whitelist(['new']);
      when(whitelistRepository.addToWhitelist('new'))
          .thenAnswer((_) => Future.value(whitelist));

      expectLater(
          whitelistBloc.state,
          emitsInOrder([
            BlocStateEmpty<Whitelist>(),
            BlocStateLoading<Whitelist>(),
            BlocStateSuccess<Whitelist>(whitelist),
          ]));

          whitelistBloc.dispatch(Add('new'));
    });

    test(
        'emits [BlocStateEmpty<Whitelist>, BlocStateLoading<Whitelist>, BlocStateError<Whitelist>] when whitelist repository add fails',
        () {
      when(whitelistRepository.addToWhitelist('new'))
          .thenThrow(PiholeException());

      expectLater(
          whitelistBloc.state,
          emitsInOrder([
            BlocStateEmpty<Whitelist>(),
            BlocStateLoading<Whitelist>(),
            BlocStateError<Whitelist>(PiholeException()),
          ]));

      whitelistBloc.dispatch(Add('new'));
    });
  });

  group('Remove', () {
    test(
        'emits [BlocStateEmpty<Whitelist>, BlocStateLoading<Whitelist>, BlocStateSuccess<Whitelist>] when whitelist repository removes succesfully',
        () {
      whitelistRepository.cache = Whitelist();
      when(whitelistRepository.removeFromWhitelist('remove'))
          .thenAnswer((_) => Future.value(Whitelist()));

      expectLater(
          whitelistBloc.state,
          emitsInOrder([
            BlocStateEmpty<Whitelist>(),
            BlocStateLoading<Whitelist>(),
            BlocStateSuccess<Whitelist>(Whitelist()),
          ]));

      whitelistBloc.dispatch(Remove('remove'));
    });

    test(
        'emits [BlocStateEmpty<Whitelist>, BlocStateLoading<Whitelist>, BlocStateError<Whitelist>] when whitelist repository add fails',
        () {
      when(whitelistRepository.removeFromWhitelist('new'))
          .thenThrow(PiholeException());

      expectLater(
          whitelistBloc.state,
          emitsInOrder([
            BlocStateEmpty<Whitelist>(),
            BlocStateLoading<Whitelist>(),
            BlocStateError<Whitelist>(PiholeException()),
          ]));

      whitelistBloc.dispatch(Remove('new'));
    });
  });

  group('Edit', () {
    setUp(() {
      whitelistRepository.cache = Whitelist(['old']);
    });
    test(
        'emits [BlocStateEmpty<Whitelist>, BlocStateLoading<Whitelist>, BlocStateSuccess<Whitelist>] when whitelist repository edits succesfully',
            () {
          final Whitelist whitelistNew = Whitelist(['new']);
          when(whitelistRepository.editOnWhitelist('old', 'new'))
              .thenAnswer((_) => Future.value(whitelistNew));

          expectLater(
              whitelistBloc.state,
              emitsInOrder([
                BlocStateEmpty<Whitelist>(),
                BlocStateLoading<Whitelist>(),
                BlocStateSuccess<Whitelist>(whitelistNew),
              ]));

          whitelistBloc.dispatch(Edit('old', 'new'));
        });

    test(
        'emits [BlocStateEmpty<Whitelist>, BlocStateLoading<Whitelist>, BlocStateError<Whitelist>] when whitelist repository edit fails',
            () {
          when(whitelistRepository.editOnWhitelist('old', 'new'))
              .thenThrow(PiholeException());

          expectLater(
              whitelistBloc.state,
              emitsInOrder([
                BlocStateEmpty<Whitelist>(),
                BlocStateLoading<Whitelist>(),
                BlocStateError<Whitelist>(PiholeException()),
              ]));

          whitelistBloc.dispatch(Edit('old', 'new'));
        });
  });
}
