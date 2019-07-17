import 'dart:convert';

import 'package:equatable/equatable.dart';

/// The API model for http://pi.hole/admin/api.php?list=white.
class Whitelist extends Equatable {
  /// The list of whitelisted domains.
  List<String> list;

  Whitelist({this.list = const []}) : super([list]);

  Whitelist.add(Whitelist whitelist, String domain) {
    this.list = whitelist.list;
    this.list.add(domain);
  }

  /// Returns a json String representation of [list].
  String toJson() => json.encode(List<dynamic>.from([list]));

  factory Whitelist.fromString(String str) =>
      Whitelist(list: List<String>.from(json.decode(str)[0])
        ..sort());

  factory Whitelist.fromJson(List<dynamic> json) =>
      Whitelist(list: List<String>.from(json[0])
        ..sort());
}
