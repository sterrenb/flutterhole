// For example queries, see https://github.com/pi-hole/AdminLTE/blob/44aff727e59d129e6201341caa1d74c8b2954bd2/scripts/pi-hole/js/queries.js.

import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutterhole/model/serializable.dart';

DateTime epochToDateTime(String source) =>
    DateTime.fromMillisecondsSinceEpoch(int.parse(source + '000'));

enum QueryType {
  A,
  AAAA,
  ANY,
  SRV,
  SOA,
  PTR,
  TXT,
  UNKN,
}

QueryType stringToQueryType(String json) {
  for (QueryType type in QueryType.values) {
    if (type.toString().contains(json
        .split(' ')
        .first)) return type;
  }

  return QueryType.values.last;
}

enum QueryStatus {
  BlockedWithGravity,
  Forwarded,
  Cached,
  BlockedWithRegexWildcard,
  BlockedWithBlacklist,
  BlockedWithExternalIP,
  BlockedWithExternalNull,
  BlockedWithExternalNXRA,
  Unknown,
}

enum DnsSecStatus {
  Secure,
  Insecure,
  Bogus,
  Abandoned,
  Unknown,
  Empty,
}

class Query extends Equatable {
  final DateTime time;
  final QueryType queryType;
  final String entry;
  final String client;
  final QueryStatus queryStatus;
  final DnsSecStatus dnsSecStatus;

  Query({
    this.time,
    this.queryType,
    this.entry,
    this.client,
    this.queryStatus,
    this.dnsSecStatus,
  }) : super([
    time,
    queryType,
    entry,
    client,
    queryStatus,
    dnsSecStatus,
  ]);

  factory Query.fromJson(List<dynamic> json) =>
      Query(
        time: epochToDateTime(json[0]),
        queryType: stringToQueryType(json[1]),
        entry: json[2],
        client: json[3],
        queryStatus: _stringToQueryStatus(json[4]),
        dnsSecStatus: _stringToDnsSecStatus(json[5]),
      );

  // https://github.com/pi-hole/AdminLTE/blob/44aff727e59d129e6201341caa1d74c8b2954bd2/scripts/pi-hole/js/queries.js#L158
  static DnsSecStatus _stringToDnsSecStatus(String json) {
    final int index = int.parse(json);

    if (index > DnsSecStatus.values.length || index == 0)
      return DnsSecStatus.values.last;

    return DnsSecStatus.values[index - 1];
  }

  // https://github.com/pi-hole/AdminLTE/blob/44aff727e59d129e6201341caa1d74c8b2954bd2/scripts/pi-hole/js/queries.js#L181
  static QueryStatus _stringToQueryStatus(String json) {
    final int index = int.parse(json);

    if (index > QueryStatus.values.length || index == 0)
      return QueryStatus.values.last;

    return QueryStatus.values[index - 1];
  }
}

class QueryTypes extends Serializable {
  final Map<String, double> queryTypes;

  QueryTypes([
    this.queryTypes,
  ]);

  factory QueryTypes.fromString(String str) =>
      QueryTypes.fromJson(json.decode(str));

//  String toRawJson() => json.encode(toJson());

  factory QueryTypes.fromJson(Map<String, dynamic> json) =>
      QueryTypes(
        Map.from(json["querytypes"]).map((k, v) {
          if (v is int) v = v.toDouble();
          return MapEntry<String, double>(k, v);
        }),
      );

  Map<String, dynamic> toJson() =>
      {
        "querytypes":
        Map.from(queryTypes).map((k, v) => MapEntry<String, dynamic>(k, v)),
      };
}
