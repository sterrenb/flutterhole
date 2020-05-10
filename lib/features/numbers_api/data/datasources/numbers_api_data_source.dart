abstract class NumbersApiDataSource {
  Future<String> fetchTrivia(int integer);

  Future<Map<int, String>> fetchManyTrivia(List<int> integers);
}
