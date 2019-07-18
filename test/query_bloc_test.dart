import 'package:flutterhole/bloc/query/bloc.dart';
import 'package:flutterhole/model/query.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockQueryRepository extends Mock implements QueryRepository {}

main() {
  MockQueryRepository queryRepository;
  QueryBloc queryBloc;

  setUp(() {
    queryRepository = MockQueryRepository();
    queryBloc = QueryBloc(queryRepository);
  });

  test('has a correct initialState', () {
    expect(queryBloc.initialState, QueryStateEmpty());
  });

  group('FetchQueries', () {
    test(
        'emits [QueryStateEmpty, QueryStateLoading, QueryStateSuccess] when Query repository returns Query',
        () {
      final List<Query> queries = [];

      when(queryRepository.getQueries())
          .thenAnswer((_) => Future.value(queries));

      expectLater(
          queryBloc.state,
          emitsInOrder([
            QueryStateEmpty(),
            QueryStateLoading(),
            QueryStateSuccess(queries),
          ]));

      queryBloc.dispatch(FetchQueries());
    });

    test(
        'emits [QueryStateEmpty, QueryStateLoading, QueryStateError] when Query repository throws PiholeException',
        () {
          when(queryRepository.getQueries()).thenThrow(PiholeException());

      expectLater(
          queryBloc.state,
          emitsInOrder([
            QueryStateEmpty(),
            QueryStateLoading(),
            QueryStateError(e: PiholeException()),
          ]));

      queryBloc.dispatch(FetchQueries());
    });
  });
}
