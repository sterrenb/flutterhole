import 'dart:convert';

import 'package:flutterhole/model/serializable.dart';

class ClientsOverTime extends Serializable {
  Map<String, List<int>> overTime;

  ClientsOverTime({
    this.overTime,
  }) : super([overTime]);

  factory ClientsOverTime.fromString(String str) =>
      ClientsOverTime.fromJson(json.decode(str));

  factory ClientsOverTime.fromJson(Map<String, dynamic> json) =>
      ClientsOverTime(
        overTime: Map.from(json["over_time"]).map((k, v) =>
            MapEntry<String, List<int>>(k, List<int>.from(v.map((x) => x)))),
      );

  @override
  Map<String, dynamic> toJson() => {
        "over_time": Map.from(overTime).map((k, v) =>
            MapEntry<String, dynamic>(k, List<dynamic>.from(v.map((x) => x)))),
      };
}
