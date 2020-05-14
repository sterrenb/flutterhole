abstract class NumbersApiDataSource {
  static const String baseUrl = 'http://numbersapi.com/';
  static const Duration maxAge = Duration(days: 30);

  /// http://numbersapi.com/[integer]
  Future<String> fetchTrivia(int integer);

  /// http://numbersapi.com/[integers]
  Future<Map<int, String>> fetchManyTrivia(List<int> integers);
}
