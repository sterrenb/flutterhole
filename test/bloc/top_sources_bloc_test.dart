import 'package:flutterhole/bloc/top_sources/bloc.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../mock.dart';

class MockTopSourcesRepository extends Mock implements TopSourcesRepository {}

main() {
  MockTopSourcesRepository topSourcesRepository;
  TopSourcesBloc topSourcesBloc;

  setUp(() {
    topSourcesRepository = MockTopSourcesRepository();
    topSourcesBloc = TopSourcesBloc(topSourcesRepository);
  });

  test('has a correct initialState', () {
    expect(topSourcesBloc.initialState, TopSourcesStateEmpty());
  });

  group('FetchTopSources', () {
    test(
        'emits [TopSourcesStateEmpty, TopSourcesStateLoading, TopSourcesStateSuccess] when repository returns TopSources',
        () {
      when(topSourcesRepository.getTopSources())
          .thenAnswer((_) => Future.value(mockTopSources));

      expectLater(
          topSourcesBloc.state,
          emitsInOrder([
            TopSourcesStateEmpty(),
            TopSourcesStateLoading(),
            TopSourcesStateSuccess(mockTopSources),
          ]));

      topSourcesBloc.dispatch(FetchTopSources());
    });

    test(
        'emits [TopSourcesStateEmpty, TopSourcesStateLoading, TopSourcesStateError] when dashboard repository throws PiholeException',
        () {
      when(topSourcesRepository.getTopSources()).thenThrow(PiholeException());

      expectLater(
          topSourcesBloc.state,
          emitsInOrder([
            TopSourcesStateEmpty(),
            TopSourcesStateLoading(),
            TopSourcesStateError(e: PiholeException()),
          ]));

      topSourcesBloc.dispatch(FetchTopSources());
    });
  });
}
