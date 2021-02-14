import 'package:flutterhole_web/entities.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

num _valueToNum(dynamic value) {
  if (value is num) return value;
  if (value is String) return num.parse(value);
  throw Exception('unknown NumString: $value (${value.runtimeType})');
}

@freezed
abstract class SummaryModel with _$SummaryModel {
  factory SummaryModel({
    @JsonKey(fromJson: _valueToNum, name: 'domains_being_blocked')
        num domainsBeingBlocked,
    @JsonKey(fromJson: _valueToNum, name: 'dns_queries_today')
        num dnsQueriesToday,
    @JsonKey(fromJson: _valueToNum, name: 'ads_blocked_today')
        num adsBlockedToday,
    @JsonKey(fromJson: _valueToNum, name: 'ads_percentage_today')
        num adsPercentageToday,
    @JsonKey(fromJson: _valueToNum, name: 'unique_domains') num uniqueDomains,
    @JsonKey(fromJson: _valueToNum, name: 'queries_forwarded')
        num queriesForwarded,
    @JsonKey(fromJson: _valueToNum, name: 'queries_cached') num queriesCached,
    @JsonKey(fromJson: _valueToNum, name: 'clients_ever_seen')
        num clientsEverSeen,
    @JsonKey(fromJson: _valueToNum, name: 'unique_clients') num uniqueClients,
    @JsonKey(fromJson: _valueToNum, name: 'dns_queries_all_types')
        num dnsQueriesAllTypes,
    @JsonKey(fromJson: _valueToNum, name: 'reply_NODATA') num replyNoData,
    @JsonKey(fromJson: _valueToNum, name: 'reply_NXDOMAIN') num replyNxDomain,
    @JsonKey(fromJson: _valueToNum, name: 'reply_CNAME') num replyCName,
    @JsonKey(fromJson: _valueToNum, name: 'reply_IP') num replyIP,
    @JsonKey(fromJson: _valueToNum, name: 'privacy_level') num privacyLevel,
    @JsonKey(name: 'status') String status,
  }) = _SummaryModel;

  factory SummaryModel.fromJson(Map<String, dynamic> json) =>
      _$SummaryModelFromJson(json);

  @late
  Summary get entity => Summary(
        domainsBeingBlocked: domainsBeingBlocked?.toInt(),
        dnsQueriesToday: dnsQueriesToday?.toInt() ?? -1,
        adsBlockedToday: adsBlockedToday?.toInt() ?? -1,
        adsPercentageToday: adsPercentageToday?.toDouble() ?? -1.0,
        uniqueDomains: uniqueDomains?.toInt() ?? -1,
        queriesForwarded: queriesForwarded?.toInt() ?? -1,
        queriesCached: queriesCached?.toInt() ?? -1,
        clientsEverSeen: clientsEverSeen?.toInt() ?? -1,
        uniqueClients: uniqueClients?.toInt() ?? -1,
        dnsQueriesAllTypes: dnsQueriesAllTypes?.toInt() ?? -1,
        replyNoData: replyNoData?.toInt() ?? -1,
        replyNxDomain: replyNxDomain?.toInt() ?? -1,
        replyCName: replyCName?.toInt() ?? -1,
        replyIP: replyIP?.toInt() ?? -1,
        privacyLevel: privacyLevel?.toInt() ?? -1,
        status: status == 'enabled' ? PiStatus.enabled : PiStatus.disabled,
      );
}

@freezed
abstract class PiQueryTypesModel with _$PiQueryTypesModel {
  factory PiQueryTypesModel({
    @JsonKey(name: 'querytypes') Map<String, double> types,
  }) = _PiQueryTypesModel;

  @late
  PiQueryTypes get entity => PiQueryTypes(types: types);

  factory PiQueryTypesModel.fromJson(Map<String, dynamic> json) =>
      _$PiQueryTypesModelFromJson(json);
}

@freezed
abstract class PiForwardDestinationsModel with _$PiForwardDestinationsModel {
  factory PiForwardDestinationsModel({
    @JsonKey(name: 'forward_destinations') Map<String, double> destinations,
  }) = _PiForwardDestinationsModel;

  @late
  PiForwardDestinations get entity => PiForwardDestinations(
      destinations: destinations
          .map((key, value) => MapEntry(key.split('|').first, value)));

  factory PiForwardDestinationsModel.fromJson(Map<String, dynamic> json) =>
      _$PiForwardDestinationsModelFromJson(json);
}

@freezed
abstract class PiQueriesOverTimeModel with _$PiQueriesOverTimeModel {
  factory PiQueriesOverTimeModel({
    @JsonKey(name: 'domains_over_time') Map<String, int> domainsOverTime,
    @JsonKey(name: 'ads_over_time') Map<String, int> adsOverTime,
  }) = _PiQueriesOverTimeModel;

  @late
  PiQueriesOverTime get entity => PiQueriesOverTime(
        domainsOverTime: domainsOverTime.map((key, value) => MapEntry(
            DateTime.fromMillisecondsSinceEpoch(int.parse(key) * 1000), value)),
        adsOverTime: adsOverTime.map((key, value) => MapEntry(
            DateTime.fromMillisecondsSinceEpoch(int.parse(key) * 1000), value)),
      );

  factory PiQueriesOverTimeModel.fromJson(Map<String, dynamic> json) =>
      _$PiQueriesOverTimeModelFromJson(json);
}
