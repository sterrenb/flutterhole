import 'package:flutterhole/bloc/api/client_names.dart';
import 'package:flutterhole/bloc/base/event.dart';
import 'package:flutterhole/bloc/base/state.dart';
import 'package:flutterhole/model/api/client_names.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../mock.dart';

class MockClientNamesRepository extends Mock implements ClientNamesRepository {}

main() {
  group('bloc', () {
    MockClientNamesRepository clientNamesRepository;
    ClientNamesBloc clientNamesBloc;

    setUp(() {
      clientNamesRepository = MockClientNamesRepository();
      clientNamesBloc = ClientNamesBloc(clientNamesRepository);
    });

    test('has a correct initialState', () {
      expect(clientNamesBloc.initialState, BlocStateEmpty<ClientNames>());
    });

    group('Fetch', () {
      test(
          'emits [BlocStateEmpty<ClientNames>, BlocStateLoading<ClientNames>, BlocStateSuccess<ClientNames>] when repository returns ClientNames',
          () {
        when(clientNamesRepository.get())
            .thenAnswer((_) => Future.value(mockClientNames));

        expectLater(
            clientNamesBloc.state,
            emitsInOrder([
              BlocStateEmpty<ClientNames>(),
              BlocStateLoading<ClientNames>(),
              BlocStateSuccess<ClientNames>(mockClientNames),
            ]));

        clientNamesBloc.dispatch(Fetch());
      });

      test(
          'emits [BlocStateEmpty<ClientNames>, BlocStateLoading<ClientNames>, BlocStateError<ClientNames>] when home repository throws PiholeException',
          () {
        when(clientNamesRepository.get()).thenThrow(PiholeException());

        expectLater(
            clientNamesBloc.state,
            emitsInOrder([
              BlocStateEmpty<ClientNames>(),
              BlocStateLoading<ClientNames>(),
              BlocStateError<ClientNames>(PiholeException()),
            ]));

        clientNamesBloc.dispatch(Fetch());
      });
    });
  });

  group('repository', () {
    MockPiholeClient client;
    ClientNamesRepository clientNamesRepository;

    setUp(() {
      client = MockPiholeClient();
      clientNamesRepository = ClientNamesRepository(client);
    });

    test('getClientNames', () {
      when(client.fetchClientNames())
          .thenAnswer((_) => Future.value(mockClientNames));
      expect(clientNamesRepository.get(), completion(mockClientNames));
    });
  });
}
