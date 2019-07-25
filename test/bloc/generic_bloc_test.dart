import 'package:flutterhole/bloc/generic/bloc.dart';
import 'package:flutterhole/bloc/generic/repository.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockGenericRepository extends Mock implements GenericRepository<int> {}

class IntBloc extends GenericBloc<int> {
  IntBloc(GenericRepository<int> genericRepository) : super(genericRepository);
}

main() {
  MockGenericRepository intRepository;
  IntBloc intBloc;

  setUp(() {
    intRepository = MockGenericRepository();
    intBloc = IntBloc(intRepository);
  });

  test('has a correct initialState', () {
    expect(intBloc.initialState, GenericStateEmpty<int>());
  });

  group('FetchGeneric', () {
    test(
        'emits [GenericStateEmpty, GenericStateLoading, GenericStateSuccess] when repository returns value',
        () {
      when(intRepository.get()).thenAnswer((_) => Future.value(5));

      expectLater(
          intBloc.state,
          emitsInOrder([
            GenericStateEmpty<int>(),
            GenericStateLoading<int>(),
            GenericStateSuccess<int>(5),
          ]));

      intBloc.dispatch(Fetch());
    });

    test(
        'emits [GenericStateEmpty, GenericStateLoading, GenericStateError] when home repository throws PiholeException',
        () {
      when(intRepository.get()).thenThrow(PiholeException());

      expectLater(
          intBloc.state,
          emitsInOrder([
            GenericStateEmpty<int>(),
            GenericStateLoading<int>(),
            GenericStateError<int>(PiholeException()),
          ]));

      intBloc.dispatch(Fetch());
    });
  });
}
