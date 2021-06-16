num numFromJson(dynamic value) {
  if (value is num) return value;
  if (value is String) return num.parse(value);
  throw Exception('unknown NumString: $value (${value.runtimeType})');
}

DateTime piQueriesStringToDateTime(String key) =>
    DateTime.fromMillisecondsSinceEpoch(int.tryParse(key) ?? 0 * 1000);

DateTime dateTimeFromPiholeString(String key) =>
    DateTime.fromMillisecondsSinceEpoch(int.tryParse(key + '000') ?? 0);
