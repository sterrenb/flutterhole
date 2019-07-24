import 'package:flutterhole/bloc/forward_destinations/bloc.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../mock.dart';

class MockForwardDestinationsRepository extends Mock
    implements ForwardDestinationsRepository {}

main() {
  MockForwardDestinationsRepository forwardDestinationsRepository;
  ForwardDestinationsBloc forwardDestinationsBloc;

  setUp(() {
    forwardDestinationsRepository = MockForwardDestinationsRepository();
    forwardDestinationsBloc =
        ForwardDestinationsBloc(forwardDestinationsRepository);
  });

  test('has a correct initialState', () {
    expect(
        forwardDestinationsBloc.initialState, ForwardDestinationsStateEmpty());
  });

  group('FetchForwardDestinations', () {
    test(
        'emits [ForwardDestinationsStateEmpty, ForwardDestinationsStateLoading, ForwardDestinationsStateSuccess] when repository returns ForwardDestinations',
        () {
      when(forwardDestinationsRepository.getForwardDestinations())
          .thenAnswer((_) => Future.value(mockForwardDestinations));

      expectLater(
          forwardDestinationsBloc.state,
          emitsInOrder([
            ForwardDestinationsStateEmpty(),
            ForwardDestinationsStateLoading(),
            ForwardDestinationsStateSuccess(mockForwardDestinations),
          ]));

      forwardDestinationsBloc.dispatch(FetchForwardDestinations());
    });

    test(
        'emits [ForwardDestinationsStateEmpty, ForwardDestinationsStateLoading, ForwardDestinationsStateError] when home repository throws PiholeException',
        () {
      when(forwardDestinationsRepository.getForwardDestinations())
          .thenThrow(PiholeException());

      expectLater(
          forwardDestinationsBloc.state,
          emitsInOrder([
            ForwardDestinationsStateEmpty(),
            ForwardDestinationsStateLoading(),
            ForwardDestinationsStateError(e: PiholeException()),
          ]));

      forwardDestinationsBloc.dispatch(FetchForwardDestinations());
    });
  });
}
