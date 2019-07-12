import 'package:flutterhole_again/bloc/summary/summary_bloc.dart';
import 'package:flutterhole_again/bloc/summary/summary_event.dart';
import 'package:flutterhole_again/bloc/summary/summary_state.dart';
import 'package:flutterhole_again/model/summary.dart';
import 'package:flutterhole_again/repository/summary_repository.dart';
import 'package:flutterhole_again/service/pihole_exception.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

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
        'emits [SummaryStateEmpty, SummaryStateLoading, SummaryStateSuccess] when summary repository returns Summary',
        () {
      final Summary summary = Summary(
        domainsBeingBlocked: 1,
        dnsQueriesToday: 2,
        adsPercentageToday: 1.23,
      );

      when(summaryRepository.getSummary())
          .thenAnswer((_) => Future.value(summary));

      expectLater(
          summaryBloc.state,
          emitsInOrder([
            SummaryStateEmpty(),
            SummaryStateLoading(),
            SummaryStateSuccess(summary),
          ]));

      summaryBloc.dispatch(FetchSummary());
    });

    test(
        'emits [SummaryStateEmpty, SummaryStateLoading, SummaryStateError] when summary repository throws PiholeException',
        () {
      when(summaryRepository.getSummary()).thenThrow(PiholeException());

      expectLater(
          summaryBloc.state,
          emitsInOrder([
            SummaryStateEmpty(),
            SummaryStateLoading(),
            SummaryStateError(),
          ]));

      summaryBloc.dispatch(FetchSummary());
    });
  });
}
