// http://pi.hole/admin/api.php?overTimeData10mins

import 'dart:convert';

import 'package:flutterhole/model/serializable.dart';

class QueriesOverTime extends Serializable {
  Map<String, int> domainsOverTime;
  Map<String, int> adsOverTime;

  QueriesOverTime({
    this.domainsOverTime,
    this.adsOverTime,
  });

  factory QueriesOverTime.fromString(String str) =>
      QueriesOverTime.fromJson(json.decode(str));

//  String toRawJson() => json.encode(toJson());

  factory QueriesOverTime.fromJson(Map<String, dynamic> json) =>
      new QueriesOverTime(
        domainsOverTime: new Map.from(json["domains_over_time"])
            .map((k, v) => new MapEntry<String, int>(k, v)),
        adsOverTime: new Map.from(json["ads_over_time"])
            .map((k, v) => new MapEntry<String, int>(k, v)),
      );

  Map<String, dynamic> toJson() => {
    "domains_over_time": new Map.from(domainsOverTime)
        .map((k, v) => new MapEntry<String, dynamic>(k, v)),
    "ads_over_time": new Map.from(adsOverTime)
        .map((k, v) => new MapEntry<String, dynamic>(k, v)),
      };
}
