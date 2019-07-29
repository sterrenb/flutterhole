import 'package:flutterhole/bloc/api/query_types.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/query.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../mock.dart';

class MockQueryTypesRepository extends Mock implements QueryTypesRepository {}

main() {
  MockQueryTypesRepository queryTypesRepository;
  QueryTypesBloc queryTypesBloc;

  setUp(() {
    queryTypesRepository = MockQueryTypesRepository();
    queryTypesBloc = QueryTypesBloc(queryTypesRepository);
  });

  test('has a correct initialState', () {
    expect(queryTypesBloc.initialState, BlocStateEmpty<QueryTypes>());
  });

  group('FetchQueryTypes', () {
    test(
        'emits [BlocStateEmpty<QueryTypes>, BlocStateLoading<QueryTypes>, BlocStateSuccess<QueryTypes>] when repository returns QueryTypes',
            () {
          when(queryTypesRepository.get())
              .thenAnswer((_) => Future.value(mockQueryTypes));

          expectLater(
              queryTypesBloc.state,
              emitsInOrder([
                BlocStateEmpty<QueryTypes>(),
                BlocStateLoading<QueryTypes>(),
                BlocStateSuccess<QueryTypes>(mockQueryTypes),
              ]));

          queryTypesBloc.dispatch(Fetch());
        });

    test(
        'emits [BlocStateEmpty<QueryTypes>, BlocStateLoading<QueryTypes>, BlocStateError<QueryTypes>] when home repository throws PiholeException',
            () {
          when(queryTypesRepository.get()).thenThrow(PiholeException());

          expectLater(
              queryTypesBloc.state,
              emitsInOrder([
                BlocStateEmpty<QueryTypes>(),
                BlocStateLoading<QueryTypes>(),
                BlocStateError<QueryTypes>(PiholeException()),
              ]));

          queryTypesBloc..dispatch(Fetch());
        });
  });
}
