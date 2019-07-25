import 'package:flutterhole/bloc/base/api/summary.dart';
import 'package:flutterhole/bloc/base/event.dart';
import 'package:flutterhole/bloc/base/state.dart';
import 'package:flutterhole/model/summary.dart';
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
    expect(summaryBloc.initialState, BlocStateEmpty<Summary>());
  });

  group('Fetch', () {
    test(
        'emits [GenericStateEmpty<Summary>, GenericStateLoading<Summary>, GenericStateSuccess<Summary>] when repository returns Summary',
            () {
          when(summaryRepository.get())
              .thenAnswer((_) => Future.value(mockSummary));

          expectLater(
              summaryBloc.state,
              emitsInOrder([
                BlocStateEmpty<Summary>(),
                BlocStateLoading<Summary>(),
                BlocStateSuccess<Summary>(mockSummary),
              ]));

          summaryBloc.dispatch(Fetch());
        });

    test(
        'emits [GenericStateEmpty<Summary>, GenericStateLoading<Summary>, GenericStateError<Summary>] when home repository throws PiholeException',
            () {
          when(summaryRepository.get()).thenThrow(PiholeException());

          expectLater(
              summaryBloc.state,
              emitsInOrder([
                BlocStateEmpty<Summary>(),
                BlocStateLoading<Summary>(),
                BlocStateError<Summary>(PiholeException()),
              ]));

          summaryBloc.dispatch(Fetch());
        });
  });
}
