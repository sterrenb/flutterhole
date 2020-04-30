import 'package:flutter/foundation.dart';
import 'package:flutterhole/features/api/data/models/model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'summary.freezed.dart';

part 'summary.g.dart';

/// {{ base_url  }}?summaryRaw
@freezed
abstract class Summary extends Model with _$Summary {
  const factory Summary({
    @JsonKey(name: 'domains_being_blocked') int domainsBeingBlocked,
    @JsonKey(name: 'dns_queries_today') int dnsQueriesToday,
    @JsonKey(name: 'ads_blocked_today') int adsBlockedToday,
    @JsonKey(name: 'ads_percentage_today') double adsPercentageToday,
    @JsonKey(name: 'unique_domains') int uniqueDomains,
  }) = _Summary;

  factory Summary.fromJson(Map<String, dynamic> json) =>
      _$SummaryFromJson(json);
}
