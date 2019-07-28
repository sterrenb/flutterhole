import 'dart:convert';

import 'package:flutterhole/model/serializable.dart';

/// The API model for http://pi.hole/admin/api.php?list=white.
class Whitelist extends Serializable {
  final List<String> list;

  Whitelist([this.list = const []]) : super([list]);

  factory Whitelist.withItem(Whitelist whitelist, String domain) {
    final List<String> list = List.from([
      ...whitelist.list,
      ...[domain]
    ]);
    return Whitelist(list);
  }

  factory Whitelist.withoutItem(Whitelist whitelist, String domain) {
    final List<String> list = whitelist.list.toList()
      ..remove(domain);
    return Whitelist(list);
  }

  factory Whitelist.fromString(String str) =>
      Whitelist(List<String>.from(json.decode(str)[0])..sort());

  factory Whitelist.fromJson(List<dynamic> json) =>
      Whitelist(List<String>.from(json[0])..sort());

  @override
  String toJson() => json.encode(List<dynamic>.from([list]));
}
