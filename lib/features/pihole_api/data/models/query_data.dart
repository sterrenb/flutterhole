import 'package:flutter/foundation.dart';
import 'package:flutterhole/core/convert.dart';
import 'package:flutterhole/features/pihole_api/data/models/model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'query_data.freezed.dart';
part 'query_data.g.dart';

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

enum QueryStatus {
  Unknown,
  BlockedWithGravity,
  Forwarded,
  Cached,
  BlockedWithRegexWildcard,
  BlockedWithBlacklist,
  BlockedWithExternalIP,
  BlockedWithExternalNull,
  BlockedWithExternalNXRA,
}

enum DnsSecStatus {
  Empty,
  Secure,
  Insecure,
  Bogus,
  Abandoned,
  Unknown,
}

// https://github.com/pi-hole/AdminLTE/blob/44aff727e59d129e6201341caa1d74c8b2954bd2/scripts/pi-hole/js/queries.js#L158
DnsSecStatus _stringToDnsSecStatus(String json) {
  final int index = int.parse(json);

  if (index > DnsSecStatus.values.length || index == 0)
    return DnsSecStatus.values.first;

  return DnsSecStatus.values[index - 1];
}

// https://github.com/pi-hole/AdminLTE/blob/44aff727e59d129e6201341caa1d74c8b2954bd2/scripts/pi-hole/js/queries.js#L181
QueryStatus _stringToQueryStatus(String json) {
  try {
    final int index = int.parse(json);

    if (index > QueryStatus.values.length || index == 0)
      return QueryStatus.values.first;

    return QueryStatus.values[index];
  } catch (e) {
    print('_stringToQueryStatus failed: $e');
    print('string: $json');
    return QueryStatus.Unknown;
  }
}

@freezed
abstract class QueryData extends ListModel implements _$QueryData {
  const QueryData._();

  const factory QueryData({
    DateTime timestamp,
    QueryType queryType,
    String domain,
    String clientName,
    QueryStatus queryStatus,
    DnsSecStatus dnsSecStatus,
    int replyTextIndex,
    Duration replyDuration,
    String replyText,
    String someString,
  }) = _QueryData;

  factory QueryData.fromJson(Map<String, dynamic> json) =>
      _$QueryDataFromJson(json);

  factory QueryData.fromList(List<dynamic> list) => QueryData(
        timestamp: dateTimeFromPiholeString(list.elementAt(0)),
        queryType: _$enumDecodeNullable(_$QueryTypeEnumMap, list.elementAt(1)),
        domain: list.elementAt(2) as String,
        clientName: list.elementAt(3) as String,
        queryStatus: _stringToQueryStatus(list.elementAt(4)),
        dnsSecStatus: _stringToDnsSecStatus(list.elementAt(5)),
        replyTextIndex: int.tryParse(list.elementAt(6)),
        replyDuration:
            Duration(microseconds: int.tryParse(list.elementAt(7)) * 100),
        replyText: list.elementAt(8) as String,
        someString: list.elementAt(9) as String,
      );

  @override
  List<dynamic> toList() => <dynamic>[
        piholeStringFromDateTime(timestamp),
        _$QueryTypeEnumMap[queryType],
        domain,
        clientName,
        '${QueryStatus.values.indexOf(queryStatus)}',
        '${DnsSecStatus.values.indexOf(dnsSecStatus)}',
        '$replyTextIndex',
        '${(replyDuration.inMicroseconds / 100).round()}',
        replyText,
        someString,
      ];
}
