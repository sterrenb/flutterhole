import 'dart:convert';

import 'package:flutterhole/model/serializable.dart';
import 'package:meta/meta.dart';

/// The API model for http://pi.hole/admin/api.php?topItems.
class TopItems extends Serializable {
  TopItems({
    @required this.topQueries,
    @required this.topAds,
  });

  final Map<String, int> topQueries;
  final Map<String, int> topAds;

  @override
  List<Object> get props => [topQueries, topAds];

  factory TopItems.fromString(String str) =>
      TopItems.fromJson(json.decode(str));

  factory TopItems.fromJson(Map<String, dynamic> json) =>
      TopItems(
        topQueries: Map.from(json["top_queries"])
            .map((k, v) => new MapEntry<String, int>(k, v)),
        topAds: Map.from(json["top_ads"])
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
