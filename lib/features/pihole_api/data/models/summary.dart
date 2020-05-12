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
    @JsonKey(name: 'domains_being_blocked') int domainsBeingBlocked,
    @JsonKey(name: 'dns_queries_today') int dnsQueriesToday,
    @JsonKey(name: 'ads_blocked_today') int adsBlockedToday,
    @JsonKey(name: 'ads_percentage_today') double adsPercentageToday,
    @JsonKey(name: 'unique_domains') int uniqueDomains,
    @JsonKey(name: 'queries_forwarded') int queriesForwarded,
    @JsonKey(name: 'queries_cached') int queriesCached,
    @JsonKey(name: 'clients_ever_seen') int clientsEverSeen,
    @JsonKey(name: 'unique_clients') int uniqueClients,
    @JsonKey(name: 'dns_queries_all_types') int dnsQueriesAllTypes,
    @JsonKey(name: 'reply_NODATA') int replyNoData,
    @JsonKey(name: 'reply_NXDOMAIN') int replyNxDomain,
    @JsonKey(name: 'reply_CNAME') int replyCName,
    @JsonKey(name: 'reply_IP') int replyIP,
    @JsonKey(name: 'privacy_level') int privacyLevel,
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
    @JsonKey(name: 'absolute') int absolute,
    @JsonKey(name: 'relative') GravityRelative relative,
  }) = _GravityLastUpdated;

  factory GravityLastUpdated.fromJson(Map<String, dynamic> json) =>
      _$GravityLastUpdatedFromJson(json);
}
