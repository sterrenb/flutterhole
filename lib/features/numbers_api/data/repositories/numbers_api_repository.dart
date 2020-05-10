import 'package:dartz/dartz.dart';
import 'package:flutterhole/core/models/failures.dart';

abstract class NumbersApiRepository {
  Future<Either<Failure, String>> fetchTrivia(int integer);

  Future<Either<Failure, Map<int, String>>> fetchManyTrivia(List<int> integers);
}
