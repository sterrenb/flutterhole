import 'package:flutterhole/bloc/api/summary.dart';
import 'package:flutterhole/bloc/base/event.dart';
import 'package:flutterhole/bloc/base/state.dart';
import 'package:flutterhole/model/api/summary.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../mock.dart';

class MockSummaryRepository extends Mock implements SummaryRepository {}

main() {
  MockSummaryRepository sumRepository;
  SummaryBloc sumBloc;

  setUp(() {
    sumRepository = MockSummaryRepository();
    sumBloc = SummaryBloc(sumRepository);
  });

  test('has a correct initialState', () {
    expect(sumBloc.initialState, BlocStateEmpty<Summary>());
  });

  group('FetchSum', () {
    test(
        'emits [SumStateEmpty, SumStateLoading, SumStateSuccess] when repository returns Sum',
            () {
          when(sumRepository.get()).thenAnswer((_) =>
              Future.value(mockSummary));

          expectLater(
              sumBloc.state,
              emitsInOrder([
                BlocStateEmpty<Summary>(),
                BlocStateLoading<Summary>(),
                BlocStateSuccess<Summary>(mockSummary),
              ]));

          sumBloc.dispatch(Fetch());
        });

    test(
        'emits [SumStateEmpty, SumStateLoading, SumStateError] when home repository throws PiholeException',
            () {
          when(sumRepository.get()).thenThrow(PiholeException());

          expectLater(
              sumBloc.state,
              emitsInOrder([
                BlocStateEmpty<Summary>(),
                BlocStateLoading<Summary>(),
                BlocStateError<Summary>(PiholeException()),
              ]));

          sumBloc.dispatch(Fetch());
        });
  });
}
