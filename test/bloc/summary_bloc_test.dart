import 'package:flutterhole/bloc/summary/bloc.dart';
import 'package:flutterhole/model/summary.dart';
import 'package:flutterhole/service/pihole_exception.dart';
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
        'emits [SummaryStateEmpty, SummaryStateLoading, SummaryStateSuccess] when home repository returns Summary',
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
