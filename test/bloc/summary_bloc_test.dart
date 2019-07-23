import 'package:flutterhole/bloc/summary/bloc.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../mock.dart';

class MockSummaryRepository extends Mock implements SummaryRepository {}

main() {
  MockSummaryRepository summaryRepository;
  SummaryBloc summaryBloc;

  setUp(() {
    summaryRepository = MockSummaryRepository();
    summaryBloc = SummaryBloc(summaryRepository);
  });

  test('has a correct initialState', () {
    expect(summaryBloc.initialState, SummaryStateEmpty());
  });

  group('FetchSummary', () {
    test(
        'emits [SummaryStateEmpty, SummaryStateLoading, SummaryStateSuccess] when repository returns Summary',
        () {
      when(summaryRepository.getSummary())
          .thenAnswer((_) => Future.value(mockSummary));

      expectLater(
          summaryBloc.state,
          emitsInOrder([
            SummaryStateEmpty(),
            SummaryStateLoading(),
            SummaryStateSuccess(mockSummary),
          ]));

      summaryBloc.dispatch(FetchSummary());
    });

    test(
        'emits [SummaryStateEmpty, SummaryStateLoading, SummaryStateError] when home repository throws PiholeException',
        () {
      when(summaryRepository.getSummary()).thenThrow(PiholeException());

      expectLater(
          summaryBloc.state,
          emitsInOrder([
            SummaryStateEmpty(),
            SummaryStateLoading(),
            SummaryStateError(e: PiholeException()),
          ]));

      summaryBloc.dispatch(FetchSummary());
    });
  });
}
