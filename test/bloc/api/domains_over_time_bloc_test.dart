import 'package:flutterhole/bloc/api/domains_over_time.dart';
import 'package:flutterhole/bloc/base/event.dart';
import 'package:flutterhole/bloc/base/state.dart';
import 'package:flutterhole/model/api/domains_over_time.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../mock.dart';

class MockDomainsOverTimeRepository extends Mock
    implements DomainsOverTimeRepository {}

main() {
  group('bloc', () {
    MockDomainsOverTimeRepository domainsOverTimeRepository;
    DomainsOverTimeBloc domainsOverTimeBloc;

    setUp(() {
      domainsOverTimeRepository = MockDomainsOverTimeRepository();
      domainsOverTimeBloc = DomainsOverTimeBloc(domainsOverTimeRepository);
    });

    test('has a correct initialState', () {
      expect(
          domainsOverTimeBloc.initialState, BlocStateEmpty<DomainsOverTime>());
    });

    group('Fetch', () {
      test(
          'emits [BlocStateEmpty<DomainsOverTime>, BlocStateLoading<DomainsOverTime>, BlocStateSuccess<DomainsOverTime>] when repository returns DomainsOverTime',
          () {
        when(domainsOverTimeRepository.get())
            .thenAnswer((_) => Future.value(mockDomainsOverTime));

        expectLater(
            domainsOverTimeBloc.state,
            emitsInOrder([
              BlocStateEmpty<DomainsOverTime>(),
              BlocStateLoading<DomainsOverTime>(),
              BlocStateSuccess<DomainsOverTime>(mockDomainsOverTime),
            ]));

        domainsOverTimeBloc.dispatch(Fetch());
      });

      test(
          'emits [BlocStateEmpty<DomainsOverTime>, BlocStateLoading<DomainsOverTime>, BlocStateError<DomainsOverTime>] when home repository throws PiholeException',
          () {
        when(domainsOverTimeRepository.get()).thenThrow(PiholeException());

        expectLater(
            domainsOverTimeBloc.state,
            emitsInOrder([
              BlocStateEmpty<DomainsOverTime>(),
              BlocStateLoading<DomainsOverTime>(),
              BlocStateError<DomainsOverTime>(PiholeException()),
            ]));

        domainsOverTimeBloc.dispatch(Fetch());
      });
    });
  });

  group('repository', () {
    MockPiholeClient client;
    DomainsOverTimeRepository domainsOverTimeRepository;

    setUp(() {
      client = MockPiholeClient();
      domainsOverTimeRepository = DomainsOverTimeRepository(client);
    });

    test('getDomainsOverTime', () {
      when(client.fetchDomainsOverTime())
          .thenAnswer((_) => Future.value(mockDomainsOverTime));
      expect(domainsOverTimeRepository.get(), completion(mockDomainsOverTime));
    });
  });
}
