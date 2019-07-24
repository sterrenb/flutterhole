import 'package:flutterhole/bloc/query_types/bloc.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../mock.dart';

class MockQueryTypesRepository extends Mock implements QueryTypesRepository {}

main() {
  MockQueryTypesRepository queryTypesRepository;
  QueryTypesBloc queryTypesBloc;

  setUp(() {
    queryTypesRepository = MockQueryTypesRepository();
    queryTypesBloc = QueryTypesBloc(queryTypesRepository);
  });

  test('has a correct initialState', () {
    expect(queryTypesBloc.initialState, QueryTypesStateEmpty());
  });

  group('FetchQueryTypes', () {
    test(
        'emits [QueryTypesStateEmpty, QueryTypesStateLoading, QueryTypesStateSuccess] when repository returns QueryTypes',
        () {
      when(queryTypesRepository.getQueryTypes())
          .thenAnswer((_) => Future.value(mockQueryTypes));

      expectLater(
          queryTypesBloc.state,
          emitsInOrder([
            QueryTypesStateEmpty(),
            QueryTypesStateLoading(),
            QueryTypesStateSuccess(mockQueryTypes),
          ]));

      queryTypesBloc.dispatch(FetchQueryTypes());
    });

    test(
        'emits [QueryTypesStateEmpty, QueryTypesStateLoading, QueryTypesStateError] when home repository throws PiholeException',
        () {
      when(queryTypesRepository.getQueryTypes()).thenThrow(PiholeException());

      expectLater(
          queryTypesBloc.state,
          emitsInOrder([
            QueryTypesStateEmpty(),
            QueryTypesStateLoading(),
            QueryTypesStateError(e: PiholeException()),
          ]));

      queryTypesBloc.dispatch(FetchQueryTypes());
    });
  });
}
