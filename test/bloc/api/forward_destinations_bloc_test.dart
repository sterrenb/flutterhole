import 'package:flutterhole/bloc/api/forward_destinations.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/forward_destinations.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../mock.dart';

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
    expect(forwardDestinationsBloc.initialState,
        BlocStateEmpty<ForwardDestinations>());
  });

  group('FetchForwardDestinations', () {
    test(
        'emits [BlocStateEmpty<ForwardDestinations>, BlocStateLoading<ForwardDestinations>, BlocStateSuccess<ForwardDestinations>] when repository returns ForwardDestinations',
            () {
          when(forwardDestinationsRepository.get())
              .thenAnswer((_) => Future.value(mockForwardDestinations));

          expectLater(
              forwardDestinationsBloc.state,
              emitsInOrder([
                BlocStateEmpty<ForwardDestinations>(),
                BlocStateLoading<ForwardDestinations>(),
                BlocStateSuccess<ForwardDestinations>(mockForwardDestinations),
              ]));

          forwardDestinationsBloc.dispatch(Fetch());
        });

    test(
        'emits [BlocStateEmpty<ForwardDestinations>, BlocStateLoading<ForwardDestinations>, BlocStateError<ForwardDestinations>] when home repository throws PiholeException',
            () {
          when(forwardDestinationsRepository.get()).thenThrow(
              PiholeException());

          expectLater(
              forwardDestinationsBloc.state,
              emitsInOrder([
                BlocStateEmpty<ForwardDestinations>(),
                BlocStateLoading<ForwardDestinations>(),
                BlocStateError<ForwardDestinations>(PiholeException()),
              ]));

          forwardDestinationsBloc.dispatch(Fetch());
        });
  });
}
