import 'package:flutterhole/bloc/api/queries_over_time.dart';
import 'package:flutterhole/bloc/base/event.dart';
import 'package:flutterhole/bloc/base/state.dart';
import 'package:flutterhole/model/api/queries_over_time.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../mock.dart';

class MockQueriesOverTimeRepository extends Mock
    implements QueriesOverTimeRepository {}

main() {
  MockQueriesOverTimeRepository queriesOverTimeRepository;
  QueriesOverTimeBloc queriesOverTimeBloc;

  setUp(() {
    queriesOverTimeRepository = MockQueriesOverTimeRepository();
    queriesOverTimeBloc = QueriesOverTimeBloc(queriesOverTimeRepository);
  });

  test('has a correct initialState', () {
    expect(queriesOverTimeBloc.initialState, BlocStateEmpty<QueriesOverTime>());
  });

  group('Fetch', () {
    test(
        'emits [BlocStateEmpty<QueriesOverTime>, BlocStateLoading<QueriesOverTime>, BlocStateSuccess<QueriesOverTime>] when repository returns QueriesOverTime',
        () {
      when(queriesOverTimeRepository.get())
          .thenAnswer((_) => Future.value(mockQueriesOverTime));

      expectLater(
          queriesOverTimeBloc.state,
          emitsInOrder([
            BlocStateEmpty<QueriesOverTime>(),
            BlocStateLoading<QueriesOverTime>(),
            BlocStateSuccess<QueriesOverTime>(mockQueriesOverTime),
          ]));

      queriesOverTimeBloc.dispatch(Fetch());
    });

    test(
        'emits [BlocStateEmpty<QueriesOverTime>, BlocStateLoading<QueriesOverTime>, BlocStateError<QueriesOverTime>] when home repository throws PiholeException',
        () {
      when(queriesOverTimeRepository.get()).thenThrow(PiholeException());

      expectLater(
          queriesOverTimeBloc.state,
          emitsInOrder([
            BlocStateEmpty<QueriesOverTime>(),
            BlocStateLoading<QueriesOverTime>(),
            BlocStateError<QueriesOverTime>(PiholeException()),
          ]));

      queriesOverTimeBloc.dispatch(Fetch());
    });
  });
}
