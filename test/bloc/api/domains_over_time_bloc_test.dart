import 'package:flutterhole/bloc/api/clients_over_time.dart';
import 'package:flutterhole/bloc/base/event.dart';
import 'package:flutterhole/bloc/base/state.dart';
import 'package:flutterhole/model/api/clients_over_time.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../mock.dart';

class MockClientsOverTimeRepository extends Mock
    implements ClientsOverTimeRepository {}

main() {
  group('bloc', () {
    MockClientsOverTimeRepository clientsOverTimeRepository;
    ClientsOverTimeBloc clientsOverTimeBloc;

    setUp(() {
      clientsOverTimeRepository = MockClientsOverTimeRepository();
      clientsOverTimeBloc = ClientsOverTimeBloc(clientsOverTimeRepository);
    });

    test('has a correct initialState', () {
      expect(
          clientsOverTimeBloc.initialState, BlocStateEmpty<ClientsOverTime>());
    });

    group('Fetch', () {
      test(
          'emits [BlocStateEmpty<ClientsOverTime>, BlocStateLoading<ClientsOverTime>, BlocStateSuccess<ClientsOverTime>] when repository returns ClientsOverTime',
          () {
            when(clientsOverTimeRepository.get())
                .thenAnswer((_) => Future.value(mockClientsOverTime));

        expectLater(
            clientsOverTimeBloc.state,
            emitsInOrder([
              BlocStateEmpty<ClientsOverTime>(),
              BlocStateLoading<ClientsOverTime>(),
              BlocStateSuccess<ClientsOverTime>(mockClientsOverTime),
            ]));

            clientsOverTimeBloc.dispatch(Fetch());
      });

      test(
          'emits [BlocStateEmpty<ClientsOverTime>, BlocStateLoading<ClientsOverTime>, BlocStateError<ClientsOverTime>] when home repository throws PiholeException',
          () {
            when(clientsOverTimeRepository.get()).thenThrow(PiholeException());

        expectLater(
            clientsOverTimeBloc.state,
            emitsInOrder([
              BlocStateEmpty<ClientsOverTime>(),
              BlocStateLoading<ClientsOverTime>(),
              BlocStateError<ClientsOverTime>(PiholeException()),
            ]));

            clientsOverTimeBloc.dispatch(Fetch());
      });
    });
  });

  group('repository', () {
    MockPiholeClient client;
    ClientsOverTimeRepository clientsOverTimeRepository;

    setUp(() {
      client = MockPiholeClient();
      clientsOverTimeRepository = ClientsOverTimeRepository(client);
    });

    test('getClientsOverTime', () {
      when(client.fetchClientsOverTime())
          .thenAnswer((_) => Future.value(mockClientsOverTime));
      expect(clientsOverTimeRepository.get(), completion(mockClientsOverTime));
    });
  });
}
