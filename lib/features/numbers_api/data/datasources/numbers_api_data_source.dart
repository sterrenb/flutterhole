abstract class NumbersApiDataSource {
  static const String baseUrl = 'http://numbersapi.com/';
  static const Duration maxAge = Duration(days: 30);

  Future<String> fetchTrivia(int integer);

  Future<Map<int, String>> fetchManyTrivia(List<int> integers);
}
