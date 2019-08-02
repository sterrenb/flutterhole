import 'package:flutterhole/bloc/api/query.dart';
import 'package:flutterhole/bloc/api/query_types.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/query.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../mock.dart';

class MockQueryRepository extends Mock implements QueryRepository {}

main() {
  group('bloc', () {
    MockQueryRepository queryRepository;
    QueryBloc queryBloc;

    setUp(() {
      queryRepository = MockQueryRepository();
      queryBloc = QueryBloc(queryRepository);
    });

    test('has a correct initialState', () {
      expect(queryBloc.initialState, BlocStateEmpty<List<Query>>());
    });

    group('FetchQuery', () {
      test(
          'emits [BlocStateEmpty<List<Query>>, BlocStateLoading<List<Query>>, BlocStateSuccess<List<Query>>] when repository returns Query',
              () {
            when(queryRepository.get())
                .thenAnswer((_) => Future.value(mockQueries));

            expectLater(
                queryBloc.state,
                emitsInOrder([
                  BlocStateEmpty<List<Query>>(),
                  BlocStateLoading<List<Query>>(),
                  BlocStateSuccess<List<Query>>(mockQueries),
                ]));

            queryBloc.dispatch(Fetch());
          });

      test(
          'emits [BlocStateEmpty<List<Query>>, BlocStateLoading<List<Query>>, BlocStateError<List<Query>>] when home repository throws PiholeException',
              () {
            when(queryRepository.get()).thenThrow(PiholeException());

            expectLater(
                queryBloc.state,
                emitsInOrder([
                  BlocStateEmpty<List<Query>>(),
                  BlocStateLoading<List<Query>>(),
                  BlocStateError<List<Query>>(PiholeException()),
                ]));

            queryBloc..dispatch(Fetch());
          });
    });

    group('FetchQueryForClient', () {
      test(
          'emits [BlocStateEmpty<List<Query>>, BlocStateLoading<List<Query>>, BlocStateSuccess<List<Query>>] when repository returns Query',
              () {
            when(queryRepository.getForClient('client'))
                .thenAnswer((_) => Future.value(mockQueries));

            expectLater(
                queryBloc.state,
                emitsInOrder([
                  BlocStateEmpty<List<Query>>(),
                  BlocStateLoading<List<Query>>(),
                  BlocStateSuccess<List<Query>>(mockQueries),
                ]));

            queryBloc.dispatch(FetchForClient('client'));
          });

      test(
          'emits [BlocStateEmpty<List<Query>>, BlocStateLoading<List<Query>>, BlocStateError<List<Query>>] when home repository throws PiholeException',
              () {
            when(queryRepository.getForClient('client'))
                .thenThrow(PiholeException());

            expectLater(
                queryBloc.state,
                emitsInOrder([
                  BlocStateEmpty<List<Query>>(),
                  BlocStateLoading<List<Query>>(),
                  BlocStateError<List<Query>>(PiholeException()),
                ]));

            queryBloc..dispatch(FetchForClient('client'));
          });
    });

    group('FetchQueryForQueryType', () {
      test(
          'emits [BlocStateEmpty<List<Query>>, BlocStateLoading<List<Query>>, BlocStateSuccess<List<Query>>] when repository returns Query',
              () {
            when(queryRepository.getForQueryType(QueryType.A))
                .thenAnswer((_) => Future.value(mockQueries));

            expectLater(
                queryBloc.state,
                emitsInOrder([
                  BlocStateEmpty<List<Query>>(),
                  BlocStateLoading<List<Query>>(),
                  BlocStateSuccess<List<Query>>(mockQueries),
                ]));

            queryBloc.dispatch(FetchForQueryType(QueryType.A));
          });

      test(
          'emits [BlocStateEmpty<List<Query>>, BlocStateLoading<List<Query>>, BlocStateError<List<Query>>] when home repository throws PiholeException',
              () {
            when(queryRepository.getForQueryType(QueryType.A))
                .thenThrow(PiholeException());

            expectLater(
                queryBloc.state,
                emitsInOrder([
                  BlocStateEmpty<List<Query>>(),
                  BlocStateLoading<List<Query>>(),
                  BlocStateError<List<Query>>(PiholeException()),
                ]));

            queryBloc..dispatch(FetchForQueryType(QueryType.A));
          });
    });
  });

  group('repository', () {
    QueryRepository queryRepository;
    MockPiholeClient client;

    setUp(() {
      client = MockPiholeClient();
      queryRepository = QueryRepository(client);
    });

    test('get', () {
      when(client.fetchQueries()).thenAnswer((_) => Future.value(mockQueries));

      expect(queryRepository.get(), completion(mockQueries));
    });

    test('getForClient', () {
      when(client.fetchQueriesForClient('client'))
          .thenAnswer((_) => Future.value(mockQueries));
      expect(queryRepository.getForClient('client'), completion(mockQueries));
    });

    test('getForQueryType', () {
      when(client.fetchQueriesForQueryType(QueryType.A))
          .thenAnswer((_) => Future.value(mockQueries));
      expect(queryRepository.getForQueryType(QueryType.A),
          completion(mockQueries));
    });
  });

  group('repository', () {
    MockPiholeClient client;
    QueryTypesRepository queryTypesRepository;

    setUp(() {
      client = MockPiholeClient();
      queryTypesRepository = QueryTypesRepository(client);
    });

    test('getQueryTypes', () {
      when(client.fetchQueryTypes())
          .thenAnswer((_) => Future.value(mockQueryTypes));
      expect(queryTypesRepository.get(), completion(mockQueryTypes));
    });
  });
}
