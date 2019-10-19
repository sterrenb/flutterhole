import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutterhole/model/serializable.dart';
import 'package:meta/meta.dart';

class TopSourceItem extends Equatable {
  TopSourceItem({@required this.ipString, this.title = '', this.requests = 0});

  final String ipString;
  final String title;

  final int requests;

  @override
  List<Object> get props => [ipString, title, requests];
}

class TopSources extends Serializable {
  TopSources(this.values,);

  final Map<String, int> values;

  @override
  List<Object> get props => [values];

  List<TopSourceItem> get items {
    List<TopSourceItem> items = [];
    values.forEach((String key, int value) {
      List<String> names = key.split('|');
      items.add(TopSourceItem(
          ipString: names.last,
          title: names.length > 1 ? names.first : '',
          requests: value));
    });

    return items;
  }

  factory TopSources.fromString(String str) =>
      TopSources.fromJson(json.decode(str));

  factory TopSources.fromJson(Map<String, dynamic> json) => TopSources(
    Map.from(json["top_sources"])
        .map((k, v) => MapEntry<String, int>(k, v)),
  );

  @override
  Map<String, dynamic> toJson() => {
    "top_sources":
    Map.from(values).map((k, v) => MapEntry<String, dynamic>(k, v)),
  };
}
