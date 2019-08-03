import 'dart:convert';

import 'package:flutterhole/model/serializable.dart';

class DomainsOverTime extends Serializable {
  Map<String, List<int>> overTime;

  DomainsOverTime({
    this.overTime,
  }) : super([overTime]);

  factory DomainsOverTime.fromString(String str) =>
      DomainsOverTime.fromJson(json.decode(str));

//  String toRawJson() => json.encode(toJson());

  factory DomainsOverTime.fromJson(Map<String, dynamic> json) =>
      DomainsOverTime(
        overTime: Map.from(json["over_time"]).map((k, v) =>
            MapEntry<String, List<int>>(k, List<int>.from(v.map((x) => x)))),
      );

  @override
  Map<String, dynamic> toJson() => {
        "over_time": Map.from(overTime).map((k, v) =>
            MapEntry<String, dynamic>(k, List<dynamic>.from(v.map((x) => x)))),
      };
}
