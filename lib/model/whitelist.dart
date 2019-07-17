import 'dart:convert';

import 'package:flutterhole/model/serializable.dart';

/// The API model for http://pi.hole/admin/api.php?list=white.
class Whitelist extends Serializable {
  /// The list of whitelisted domains.
  List<String> list;

  Whitelist({this.list = const []}) : super([list]);

  Whitelist.add(Whitelist whitelist, String domain) {
    this.list = whitelist.list;
    this.list.add(domain);
  }

//  /// Returns a json String representation of [list].
//  String toJsonString() => json.encode(List<dynamic>.from([list]));

  factory Whitelist.fromString(String str) =>
      Whitelist(list: List<String>.from(json.decode(str)[0])
        ..sort());

  factory Whitelist.fromJson(List<dynamic> json) =>
      Whitelist(list: List<String>.from(json[0])
        ..sort());

  @override
  String toJson() => json.encode(List<dynamic>.from([list]));
}
