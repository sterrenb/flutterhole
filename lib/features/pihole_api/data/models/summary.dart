import 'package:flutter/foundation.dart';
import 'package:flutterhole/features/pihole_api/data/models/model.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'summary.freezed.dart';

part 'summary.g.dart';

/// {{ base_url  }}?summaryRaw
@freezed
abstract class SummaryModel extends MapModel with _$SummaryModel {
  @JsonSerializable(explicitToJson: true)
  const factory SummaryModel({
    @JsonKey(name: 'domains_being_blocked', fromJson: _valueToNum) num domainsBeingBlocked,
    @JsonKey(name: 'dns_queries_today', fromJson: _valueToNum) num dnsQueriesToday,
    @JsonKey(name: 'ads_blocked_today', fromJson: _valueToNum) num adsBlockedToday,
    @JsonKey(name: 'ads_percentage_today', fromJson: _valueToNum) num adsPercentageToday,
    @JsonKey(name: 'unique_domains', fromJson: _valueToNum) num uniqueDomains,
    @JsonKey(name: 'queries_forwarded', fromJson: _valueToNum) num queriesForwarded,
    @JsonKey(name: 'queries_cached', fromJson: _valueToNum) num queriesCached,
    @JsonKey(name: 'clients_ever_seen', fromJson: _valueToNum) num clientsEverSeen,
    @JsonKey(name: 'unique_clients', fromJson: _valueToNum) num uniqueClients,
    @JsonKey(name: 'dns_queries_all_types', fromJson: _valueToNum) num dnsQueriesAllTypes,
    @JsonKey(name: 'reply_NODATA', fromJson: _valueToNum) num replyNoData,
    @JsonKey(name: 'reply_NXDOMAIN', fromJson: _valueToNum) num replyNxDomain,
    @JsonKey(name: 'reply_CNAME', fromJson: _valueToNum) num replyCName,
    @JsonKey(name: 'reply_IP', fromJson: _valueToNum) num replyIP,
    @JsonKey(name: 'privacy_level', fromJson: _valueToNum) num privacyLevel,
    @JsonKey(name: 'status') PiStatusEnum status,
    @JsonKey(name: 'gravity_last_updated')
        GravityLastUpdated gravityLastUpdated,
  }) = _Summary;

  factory SummaryModel.fromJson(Map<String, dynamic> json) =>
      _$SummaryModelFromJson(json);
}

@freezed
abstract class GravityRelative extends MapModel with _$GravityRelative {
  const factory GravityRelative({
    int days,
    int hours,
    int minutes,
  }) = _GravityRelative;

  factory GravityRelative.fromJson(Map<String, dynamic> json) =>
      _$GravityRelativeFromJson(json);
}

@freezed
abstract class GravityLastUpdated extends MapModel with _$GravityLastUpdated {
  @JsonSerializable(explicitToJson: true)
  const factory GravityLastUpdated({
    @JsonKey(name: 'file_exists') bool fileExists,
    @JsonKey(name: 'absolute', fromJson: _valueToNum) num absolute,
    @JsonKey(name: 'relative') GravityRelative relative,
  }) = _GravityLastUpdated;

  factory GravityLastUpdated.fromJson(Map<String, dynamic> json) =>
      _$GravityLastUpdatedFromJson(json);
}

num _valueToNum(dynamic value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  throw Exception('unknown NumString type ${value.runtimeType}: value');
}