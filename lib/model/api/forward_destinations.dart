import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutterhole/model/serializable.dart';
import 'package:meta/meta.dart';

class ForwardDestinationItem extends Equatable {
  ForwardDestinationItem(
      {@required this.ipString, this.title = '', this.percent = 0});

  final String ipString;
  final String title;
  final double percent;

  @override
  List<Object> get props => [ipString, title, percent];
}

/// The API model for http://pi.hole/admin/api.php?getForwardDestinations.
class ForwardDestinations extends Serializable {
  ForwardDestinations(this.values,);

  final Map<String, double> values;

  @override
  List<Object> get props => [values];

  List<ForwardDestinationItem> get items {
    List<ForwardDestinationItem> items = [];
    values.forEach((String key, double value) {
      List<String> names = key.split('|');
      items.add(ForwardDestinationItem(
          ipString: names.last,
          title: names.length > 1 ? names.first : '',
          percent: value));
    });

    return items;
  }

  factory ForwardDestinations.fromString(String str) =>
      ForwardDestinations.fromJson(json.decode(str));

  factory ForwardDestinations.fromJson(Map<String, dynamic> json) =>
      ForwardDestinations(
        Map.from(json["forward_destinations"]).map((k, v) {
          if (v is int) v = v.toDouble();

          return MapEntry<String, double>(k, v);
        }),
      );

  @override
  Map<String, dynamic> toJson() => {
    "forward_destinations":
    Map.from(values).map((k, v) => MapEntry<String, dynamic>(k, v)),
  };
}
