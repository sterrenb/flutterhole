import 'dart:convert';

import 'package:flutterhole/model/serializable.dart';

/// The API model for http://pi.hole/admin/api.php?list=white.
class Whitelist extends Serializable {
  final List<String> list;

  Whitelist([this.list = const []]) : super([list]);

  factory Whitelist.withItem(Whitelist source, String domain) {
    List<String> list = List.from([
      ...source.list,
      ...[domain]
    ]);
    return Whitelist(list..sort());
  }

  factory Whitelist.withoutItem(Whitelist source, String domain) {
    List<String> list = source.list.toList()
      ..remove(domain);
    return Whitelist(list..sort());
  }

  factory Whitelist.fromString(String str) =>
      Whitelist(List<String>.from(json.decode(str)[0])..sort());

  factory Whitelist.fromJson(List<dynamic> json) =>
      Whitelist(List<String>.from(json[0])..sort());

  @override
  String toJson() => json.encode(List<dynamic>.from([list]));
}
