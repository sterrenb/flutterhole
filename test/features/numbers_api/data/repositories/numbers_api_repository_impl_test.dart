import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/core/models/exceptions.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/numbers_api/data/datasources/numbers_api_data_source.dart';
import 'package:flutterhole/features/numbers_api/data/repositories/numbers_api_repository_impl.dart';
import 'package:mockito/mockito.dart';

import '../../../../test_dependency_injection.dart';

class MockNumbersApiDataSource extends Mock implements NumbersApiDataSource {}

void main() async {
  await setUpAllForTest();

  NumbersApiRepositoryImpl numbersApiRepository;
  NumbersApiDataSource mockNumbersApiDataSource;

  setUp(() {
    mockNumbersApiDataSource = MockNumbersApiDataSource();
    numbersApiRepository = NumbersApiRepositoryImpl(mockNumbersApiDataSource);
  });

  final tError = PiException.emptyResponse(TypeError());

  group('fetchTrivia', () {
    test(
      'should return String on successful fetchTrivia',
      () async {
        // arrange
        final tTrivia = 'Got em';
        when(mockNumbersApiDataSource.fetchTrivia(1))
            .thenAnswer((_) async => tTrivia);
        // act
        final Either<Failure, String> result =
            await numbersApiRepository.fetchTrivia(1);
        // assert
        expect(result, equals(Right(tTrivia)));
      },
    );

    test(
      'should return $Failure on failed fetchTrivia',
      () async {
        // arrange
        when(mockNumbersApiDataSource.fetchTrivia(2)).thenThrow(tError);
        // act
        final Either<Failure, String> result =
            await numbersApiRepository.fetchTrivia(2);
        // assert
        expect(result, equals(Left(Failure('fetchTrivia failed', tError))));
      },
    );
  });

  group('fetchManyTrivia', () {
    test(
      'should return String on successful fetchManyTrivia',
      () async {
        // arrange
        final tTrivia = {
          1: 'one',
          2: 'two',
          3: 'three',
        };
        when(mockNumbersApiDataSource.fetchManyTrivia([1, 2, 3]))
            .thenAnswer((_) async => tTrivia);
        // act
        final Either<Failure, Map<int, String>> result =
            await numbersApiRepository.fetchManyTrivia([1, 2, 3]);
        // assert
        expect(result, equals(Right(tTrivia)));
      },
    );

    test(
      'should return $Failure on failed fetchManyTrivia',
      () async {
        // arrange
        when(mockNumbersApiDataSource.fetchManyTrivia([1, 2, 3]))
            .thenThrow(tError);
        // act
        final Either<Failure, Map<int, String>> result =
            await numbersApiRepository.fetchManyTrivia([1, 2, 3]);
        // assert
        expect(result, equals(Left(Failure('fetchManyTrivia failed', tError))));
      },
    );
  });
}
