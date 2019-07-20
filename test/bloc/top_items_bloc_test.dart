import 'package:flutterhole/bloc/top_items/bloc.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../mock.dart';

class MockTopItemsRepository extends Mock implements TopItemsRepository {}

main() {
  MockTopItemsRepository topItemsRepository;
  TopItemsBloc topItemsBloc;

  setUp(() {
    topItemsRepository = MockTopItemsRepository();
    topItemsBloc = TopItemsBloc(topItemsRepository);
  });

  test('has a correct initialState', () {
    expect(topItemsBloc.initialState, TopItemsStateEmpty());
  });

  group('FetchTopItems', () {
    test(
        'emits [TopItemsStateEmpty, TopItemsStateLoading, TopItemsStateSuccess] when repository returns TopItems',
        () {
      when(topItemsRepository.getTopItems())
          .thenAnswer((_) => Future.value(mockTopItems));

      expectLater(
          topItemsBloc.state,
          emitsInOrder([
            TopItemsStateEmpty(),
            TopItemsStateLoading(),
            TopItemsStateSuccess(mockTopItems),
          ]));

      topItemsBloc.dispatch(FetchTopItems());
    });

    test(
        'emits [TopItemsStateEmpty, TopItemsStateLoading, TopItemsStateError] when home repository throws PiholeException',
        () {
      when(topItemsRepository.getTopItems()).thenThrow(PiholeException());

      expectLater(
          topItemsBloc.state,
          emitsInOrder([
            TopItemsStateEmpty(),
            TopItemsStateLoading(),
            TopItemsStateError(e: PiholeException()),
          ]));

      topItemsBloc.dispatch(FetchTopItems());
    });
  });
}
