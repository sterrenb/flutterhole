abstract class NumbersApiDataSource {
  static const String baseUrl = 'http://numbersapi.com/';

  Future<String> fetchTrivia(int integer);

  Future<Map<int, String>> fetchManyTrivia(List<int> integers);
}
