import 'package:flutterhole_again/bloc/query/query_bloc.dart';
import 'package:flutterhole_again/bloc/query/query_event.dart';
import 'package:flutterhole_again/bloc/query/query_state.dart';
import 'package:flutterhole_again/model/query.dart';
import 'package:flutterhole_again/repository/query_repository.dart';
import 'package:flutterhole_again/service/pihole_exception.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockQueryRepository extends Mock implements QueryRepository {}

main() {
  MockQueryRepository QueryRepository;
  QueryBloc queryBloc;

  setUp(() {
    QueryRepository = MockQueryRepository();
    queryBloc = QueryBloc(QueryRepository);
  });

  test('has a correct initialState', () {
    expect(queryBloc.initialState, QueryStateEmpty());
  });

  group('FetchQueries', () {
    test(
        'emits [QueryStateEmpty, QueryStateLoading, QueryStateSuccess] when Query repository returns Query',
        () {
      final List<Query> queries = [];

      when(QueryRepository.getQueries())
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
      when(QueryRepository.getQueries()).thenThrow(PiholeException());

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
