import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/numbers_api/blocs/number_trivia_bloc.dart';
import 'package:flutterhole/features/numbers_api/data/repositories/numbers_api_repository.dart';
import 'package:mockito/mockito.dart';

import '../../../test_dependency_injection.dart';

class MockNumbersApiRepository extends Mock implements NumbersApiRepository {}

void main() {
  setUpAllForTest();

  NumbersApiRepository mockNumbersApiRepository;
  NumberTriviaBloc bloc;

  setUp(() {
    mockNumbersApiRepository = MockNumbersApiRepository();
    bloc = NumberTriviaBloc(mockNumbersApiRepository);
  });

  tearDown(() {
    bloc.close();
  });

  blocTest(
    'Initially emits NumberTriviaStateInitial',
    build: () async => bloc,
    skip: 0,
    expect: [NumberTriviaState.initial()],
  );

  blocTest(
    'Emits [] when nothing is added',
    build: () async => bloc,
    expect: [],
  );

  group('$NumberTriviaEventFetchMany', () {
    final tTrivia = {
      1: 'one',
      2: 'two',
      3: 'three',
    };

    blocTest(
      'Emits [$NumberTriviaStateLoading, $NumberTriviaStateSuccess] when $NumberTriviaEventFetchMany succeeds',
      build: () async {
        when(mockNumbersApiRepository.fetchManyTrivia([1, 2, 3]))
            .thenAnswer((_) async => Right(tTrivia));

        return bloc;
      },
      act: (NumberTriviaBloc bloc) async =>
          bloc.add(NumberTriviaEventFetchMany([1, 2, 3])),
      expect: [
        NumberTriviaStateLoading(),
        NumberTriviaStateSuccess(tTrivia),
      ],
    );

    final tFailure = Failure('test');

    blocTest(
      'Emits [$NumberTriviaStateLoading, $NumberTriviaStateFailure] when $NumberTriviaEventFetchMany fails',
      build: () async {
        when(mockNumbersApiRepository.fetchManyTrivia([1, 2, 3]))
            .thenAnswer((_) async => Left(tFailure));

        return bloc;
      },
      act: (NumberTriviaBloc bloc) async =>
          bloc.add(NumberTriviaEventFetchMany([1, 2, 3])),
      expect: [
        NumberTriviaStateLoading(),
        NumberTriviaStateFailure(tFailure),
      ],
    );
  });
}
