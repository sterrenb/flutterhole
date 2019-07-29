import 'package:flutterhole/bloc/api/top_sources.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/top_sources.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../mock.dart';

class MockTopSourcesRepository extends Mock implements TopSourcesRepository {}

main() {
  MockTopSourcesRepository topSourcesRepository;
  TopSourcesBloc topSourcesBloc;

  setUp(() {
    topSourcesRepository = MockTopSourcesRepository();
    topSourcesBloc = TopSourcesBloc(topSourcesRepository);
  });

  test('has a correct initialState', () {
    expect(topSourcesBloc.initialState, BlocStateEmpty<TopSources>());
  });

  group('Fetch', () {
    test(
        'emits [BlocStateEmpty<TopSources>, BlocStateLoading<TopSources>, BlocStateSuccess<TopSources>] when repository returns TopSources',
        () {
          when(topSourcesRepository.get())
          .thenAnswer((_) => Future.value(mockTopSources));

      expectLater(
          topSourcesBloc.state,
          emitsInOrder([
            BlocStateEmpty<TopSources>(),
            BlocStateLoading<TopSources>(),
            BlocStateSuccess<TopSources>(mockTopSources),
          ]));

          topSourcesBloc.dispatch(Fetch());
    });

    test(
        'emits [BlocStateEmpty<TopSources>, BlocStateLoading<TopSources>, BlocStateError<TopSources>] when home repository throws PiholeException',
        () {
          when(topSourcesRepository.get()).thenThrow(PiholeException());

      expectLater(
          topSourcesBloc.state,
          emitsInOrder([
            BlocStateEmpty<TopSources>(),
            BlocStateLoading<TopSources>(),
            BlocStateError<TopSources>(PiholeException()),
          ]));

          topSourcesBloc.dispatch(Fetch());
    });
  });
}
