import 'dart:convert';

import 'package:flutterhole/model/serializable.dart';

class TopItems extends Serializable {
  final Map<String, int> topQueries;
  final Map<String, int> topAds;

  TopItems(
    this.topQueries,
    this.topAds,
  ) : super([topQueries, topAds]);

  factory TopItems.fromString(String str) =>
      TopItems.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TopItems.fromJson(Map<String, dynamic> json) => new TopItems(
        Map.from(json["top_queries"])
            .map((k, v) => new MapEntry<String, int>(k, v)),
        Map.from(json["top_ads"])
            .map((k, v) => new MapEntry<String, int>(k, v)),
      );

  @override
  Map<String, dynamic> toJson() => {
        "top_queries": new Map.from(topQueries)
            .map((k, v) => new MapEntry<String, dynamic>(k, v)),
        "top_ads": new Map.from(topAds)
            .map((k, v) => new MapEntry<String, dynamic>(k, v)),
      };
}
