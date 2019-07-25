import 'package:flutterhole/bloc/api/top_items.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/top_items.dart';
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
    expect(topItemsBloc.initialState, BlocStateEmpty<TopItems>());
  });

  group('FetchTopItems', () {
    test(
        'emits [BlocStateEmpty<TopItems>, BlocStateLoading<TopItems>, BlocStateSuccess<TopItems>] when repository returns TopItems',
            () {
          when(topItemsRepository.get())
              .thenAnswer((_) => Future.value(mockTopItems));

          expectLater(
              topItemsBloc.state,
              emitsInOrder([
                BlocStateEmpty<TopItems>(),
                BlocStateLoading<TopItems>(),
                BlocStateSuccess<TopItems>(mockTopItems),
              ]));

          topItemsBloc.dispatch(Fetch());
        });

    test(
        'emits [BlocStateEmpty<TopItems>, BlocStateLoading<TopItems>, BlocStateError<TopItems>] when home repository throws PiholeException',
            () {
          when(topItemsRepository.get()).thenThrow(PiholeException());

          expectLater(
              topItemsBloc.state,
              emitsInOrder([
                BlocStateEmpty<TopItems>(),
                BlocStateLoading<TopItems>(),
                BlocStateError<TopItems>(PiholeException()),
              ]));

          topItemsBloc.dispatch(Fetch());
        });
  });
}
