import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// The API model for http://pi.hole/admin/api.php?list=white.
class Whitelist extends Equatable {
  /// The list of whitelisted domains.
  List<String> list;

  Whitelist({@required this.list}) : super([list]);

  /// Returns a json String representation of [list].
  String toJson() => json.encode(List<dynamic>.from([list]));

  factory Whitelist.fromString(String str) =>
      Whitelist(list: List<String>.from(json.decode(str)[0]));
}
