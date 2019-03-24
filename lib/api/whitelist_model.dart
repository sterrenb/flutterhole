// To parse this JSON data, do
//
//     final whitelist = whitelistFromJson(jsonString);

import 'dart:convert';

List<String> whitelistFromJson(String str) {
  final jsonData = json.decode(str);
  final list = List<List<String>>.from(
      jsonData.map((x) => List<String>.from(x.map((x) => x))));
  return list.first;
}
