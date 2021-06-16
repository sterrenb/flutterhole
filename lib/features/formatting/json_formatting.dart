import 'package:flutter/cupertino.dart';

num numFromJson(dynamic value) {
  if (value is num) return value;
  if (value is String) return num.parse(value);
  debugPrint('unknown NumString: $value (${value.runtimeType})');
  return -1;
}

DateTime piQueriesStringToDateTime(String key) =>
    DateTime.fromMillisecondsSinceEpoch(int.tryParse(key) ?? 0 * 1000);

DateTime dateTimeFromPiholeString(String key) =>
    DateTime.fromMillisecondsSinceEpoch(int.tryParse(key + '000') ?? 0);
