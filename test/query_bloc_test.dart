import 'package:flutterhole/bloc/api/query.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
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
    expect(queryBloc.initialState, BlocStateEmpty<List<Query>>());
  });

  group('FetchQueries', () {
    test(
        'emits [BlocStateEmpty<List<Query>>, BlocStateLoading<List<Query>>, BlocStateSuccess<List<Query>>] when Query repository returns Query',
            () {
          final List<Query> queries = [];

          when(queryRepository.get()).thenAnswer((_) => Future.value(queries));

          expectLater(
              queryBloc.state,
              emitsInOrder([
                BlocStateEmpty<List<Query>>(),
                BlocStateLoading<List<Query>>(),
                BlocStateSuccess<List<Query>>(queries),
              ]));

          queryBloc.dispatch(Fetch());
        });

    test(
        'emits [BlocStateEmpty<List<Query>>, BlocStateLoading<List<Query>>, BlocStateError<List<Query>>] when Query repository throws PiholeException',
            () {
          when(queryRepository.get()).thenThrow(PiholeException());

          expectLater(
              queryBloc.state,
              emitsInOrder([
                BlocStateEmpty<List<Query>>(),
                BlocStateLoading<List<Query>>(),
                BlocStateError<List<Query>>(PiholeException()),
              ]));

          queryBloc.dispatch(Fetch());
        });
  });
}
