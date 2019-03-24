import 'dart:convert';

List<List<String>> listFromJson(String str) {
  final jsonData = json.decode(str);
  return List<List<String>>.from(
      jsonData.map((x) => List<String>.from(x.map((x) => x))));
}
