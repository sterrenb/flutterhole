import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/bloc/base/repository.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockGenericRepository extends Mock implements BaseRepository<int> {}

class IntBloc extends BaseBloc<int> {
  IntBloc(BaseRepository<int> genericRepository) : super(genericRepository);
}

main() {
  MockGenericRepository intRepository;
  IntBloc intBloc;

  setUp(() {
    intRepository = MockGenericRepository();
    intBloc = IntBloc(intRepository);
  });

  test('has a correct initial state', () {
    expect(intBloc.initialState, BlocStateEmpty<int>());
    expect(intBloc.hasCache, isFalse);
  });

  group('FetchGeneric', () {
    test(
        'emits [BlocStateEmpty, BlocStateLoading, BlocStateSuccess] when repository returns value',
        () {
      when(intRepository.get()).thenAnswer((_) => Future.value(5));

      expectLater(
          intBloc.state,
          emitsInOrder([
            BlocStateEmpty<int>(),
            BlocStateLoading<int>(),
            BlocStateSuccess<int>(5),
          ]));

      intBloc.dispatch(Fetch());
    });

    test(
        'emits [BlocStateEmpty, BlocStateLoading, BlocStateError] when home repository throws PiholeException',
        () {
      when(intRepository.get()).thenThrow(PiholeException());

      expectLater(
          intBloc.state,
          emitsInOrder([
            BlocStateEmpty<int>(),
            BlocStateLoading<int>(),
            BlocStateError<int>(PiholeException()),
          ]));

      intBloc.dispatch(Fetch());
    });
  });
}
