// http://pi.hole/admin/api.php?overTimeData10mins

import 'dart:convert';

import 'package:flutterhole/model/serializable.dart';

class QueriesOverTime extends Serializable {
  QueriesOverTime({
    this.clientsOverTime,
    this.adsOverTime,
  });

  final Map<String, int> clientsOverTime;
  final Map<String, int> adsOverTime;

  @override
  List<Object> get props => [clientsOverTime, adsOverTime];

  factory QueriesOverTime.fromString(String str) =>
      QueriesOverTime.fromJson(json.decode(str));

  factory QueriesOverTime.fromJson(Map<String, dynamic> json) =>
      QueriesOverTime(
        clientsOverTime: Map.from(json["domains_over_time"])
            .map((k, v) => MapEntry<String, int>(k, v)),
        adsOverTime: Map.from(json["ads_over_time"])
            .map((k, v) => MapEntry<String, int>(k, v)),
      );

  Map<String, dynamic> toJson() => {
    "domains_over_time": Map.from(clientsOverTime)
        .map((k, v) => MapEntry<String, dynamic>(k, v)),
    "ads_over_time": Map.from(adsOverTime)
        .map((k, v) => MapEntry<String, dynamic>(k, v)),
      };
}
