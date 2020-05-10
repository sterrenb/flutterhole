import 'package:dartz/dartz.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/numbers_api/data/datasources/numbers_api_data_source.dart';
import 'package:flutterhole/features/numbers_api/data/repositories/numbers_api_repository.dart';
import 'package:injectable/injectable.dart';

@prod
@singleton
@RegisterAs(NumbersApiRepository)
class NumbersApiRepositoryImpl implements NumbersApiRepository {
  NumbersApiRepositoryImpl([NumbersApiDataSource numbersApiDataSource])
      : _numbersApiDataSource =
            numbersApiDataSource ?? getIt<NumbersApiDataSource>();

  final NumbersApiDataSource _numbersApiDataSource;

  @override
  Future<Either<Failure, String>> fetchTrivia(int integer) async {
    try {
      final result = await _numbersApiDataSource.fetchTrivia(integer);
      return Right(result);
    } catch (e) {
      return Left(Failure('fetchTrivia failed', e));
    }
  }

  @override
  Future<Either<Failure, Map<int, String>>> fetchManyTrivia(
      List<int> integers) async {
    try {
      final result = await _numbersApiDataSource.fetchManyTrivia(integers);
      return Right(result);
    } catch (e) {
      return Left(Failure('fetchManyTrivia failed', e));
    }
  }
}
