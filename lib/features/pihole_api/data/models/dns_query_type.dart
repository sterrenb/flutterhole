import 'package:flutter/foundation.dart';
import 'package:flutterhole/features/pihole_api/data/models/model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dns_query_type.freezed.dart';

part 'dns_query_type.g.dart';

@freezed
abstract class DnsQueryType extends MapModel with _$DnsQueryType {
  const factory DnsQueryType({String title, double fraction}) = _DnsQueryType;

  factory DnsQueryType.fromJson(Map<String, dynamic> json) =>
      _$DnsQueryTypeFromJson(json);
}

List<DnsQueryType> _valueToDnsQueryTypes(dynamic value) => (value as Map)
    .cast<String, num>()
    .entries
    .map((MapEntry<String, num> entry) =>
        DnsQueryType(title: entry.key, fraction: entry.value.toDouble()))
    .toList();

dynamic _dnsQueryTypesToValues(List<DnsQueryType> queryTypes) =>
    {for (var v in queryTypes) v.title: v.fraction};

/// {{ base_url  }}?getQueryTypes&auth={{ auth  }}
@freezed
abstract class DnsQueryTypeResult extends MapModel with _$DnsQueryTypeResult {
  const factory DnsQueryTypeResult({
    @JsonKey(
      name: 'querytypes',
      fromJson: _valueToDnsQueryTypes,
      toJson: _dnsQueryTypesToValues,
    )
        List<DnsQueryType> dnsQueryTypes,
  }) = _DnsQueryTypeResult;

  factory DnsQueryTypeResult.fromJson(Map<String, dynamic> json) =>
      _$DnsQueryTypeResultFromJson(json);
}
