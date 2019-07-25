import 'package:flutterhole/bloc/generic/event.dart';
import 'package:flutterhole/bloc/generic/pihole/bloc.dart';
import 'package:flutterhole/bloc/generic/state.dart';
import 'package:flutterhole/model/summary.dart';
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
    expect(sumBloc.initialState, GenericStateEmpty<Summary>());
  });

  group('FetchSum', () {
    test(
        'emits [SumStateEmpty, SumStateLoading, SumStateSuccess] when repository returns Sum',
        () {
      when(sumRepository.get()).thenAnswer((_) => Future.value(mockSummary));

      expectLater(
          sumBloc.state,
          emitsInOrder([
            GenericStateEmpty<Summary>(),
            GenericStateLoading<Summary>(),
            GenericStateSuccess<Summary>(mockSummary),
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
            GenericStateEmpty<Summary>(),
            GenericStateLoading<Summary>(),
            GenericStateError<Summary>(PiholeException()),
          ]));

      sumBloc.dispatch(Fetch());
    });
  });
}
