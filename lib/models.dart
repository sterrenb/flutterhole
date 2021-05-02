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
class SummaryModel with _$SummaryModel {
  SummaryModel._();
  factory SummaryModel({
    @JsonKey(fromJson: _valueToNum, name: 'domains_being_blocked')
        required num domainsBeingBlocked,
    @JsonKey(fromJson: _valueToNum, name: 'dns_queries_today')
        required num dnsQueriesToday,
    @JsonKey(fromJson: _valueToNum, name: 'ads_blocked_today')
        required num adsBlockedToday,
    @JsonKey(fromJson: _valueToNum, name: 'ads_percentage_today')
        required num adsPercentageToday,
    @JsonKey(fromJson: _valueToNum, name: 'unique_domains')
        required num uniqueDomains,
    @JsonKey(fromJson: _valueToNum, name: 'queries_forwarded')
        required num queriesForwarded,
    @JsonKey(fromJson: _valueToNum, name: 'queries_cached')
        required num queriesCached,
    @JsonKey(fromJson: _valueToNum, name: 'clients_ever_seen')
        required num clientsEverSeen,
    @JsonKey(fromJson: _valueToNum, name: 'unique_clients')
        required num uniqueClients,
    @JsonKey(fromJson: _valueToNum, name: 'dns_queries_all_types')
        required num dnsQueriesAllTypes,
    @JsonKey(fromJson: _valueToNum, name: 'reply_NODATA')
        required num replyNoData,
    @JsonKey(fromJson: _valueToNum, name: 'reply_NXDOMAIN')
        required num replyNxDomain,
    @JsonKey(fromJson: _valueToNum, name: 'reply_CNAME')
        required num replyCName,
    @JsonKey(fromJson: _valueToNum, name: 'reply_IP') required num replyIP,
    @JsonKey(fromJson: _valueToNum, name: 'privacy_level')
        required num privacyLevel,
    @JsonKey(name: 'status') required String status,
  }) = _SummaryModel;

  factory SummaryModel.fromJson(Map<String, dynamic> json) =>
      _$SummaryModelFromJson(json);

  late final Summary entity = Summary(
    domainsBeingBlocked: domainsBeingBlocked.toInt(),
    dnsQueriesToday: dnsQueriesToday.toInt(),
    adsBlockedToday: adsBlockedToday.toInt(),
    adsPercentageToday: adsPercentageToday.toDouble(),
    uniqueDomains: uniqueDomains.toInt(),
    queriesForwarded: queriesForwarded.toInt(),
    queriesCached: queriesCached.toInt(),
    clientsEverSeen: clientsEverSeen.toInt(),
    uniqueClients: uniqueClients.toInt(),
    dnsQueriesAllTypes: dnsQueriesAllTypes.toInt(),
    replyNoData: replyNoData.toInt(),
    replyNxDomain: replyNxDomain.toInt(),
    replyCName: replyCName.toInt(),
    replyIP: replyIP.toInt(),
    privacyLevel: privacyLevel.toInt(),
    status:
        status == 'enabled' ? PiholeStatus.enabled() : PiholeStatus.disabled(),
  );
}

@freezed
class PiholeStatusModel with _$PiholeStatusModel {
  PiholeStatusModel._();
  factory PiholeStatusModel({
    @JsonKey(name: 'status') required String status,
  }) = _PiholeStatusModel;

  factory PiholeStatusModel.fromJson(Map<String, dynamic> json) =>
      _$PiholeStatusModelFromJson(json);

  late final PiholeStatus entity =
      status == 'enabled' ? PiholeStatus.enabled() : PiholeStatus.disabled();
}

@freezed
class PiQueryTypesModel with _$PiQueryTypesModel {
  PiQueryTypesModel._();
  factory PiQueryTypesModel({
    @JsonKey(name: 'querytypes') required Map<String, num> types,
  }) = _PiQueryTypesModel;

  late final PiQueryTypes entity = PiQueryTypes(
      types: types.map<String, double>(
          (key, value) => MapEntry(key, value.toDouble())));

  factory PiQueryTypesModel.fromJson(Map<String, dynamic> json) =>
      _$PiQueryTypesModelFromJson(json);
}

@freezed
class PiForwardDestinationsModel with _$PiForwardDestinationsModel {
  PiForwardDestinationsModel._();
  factory PiForwardDestinationsModel({
    @JsonKey(name: 'forward_destinations')
        required Map<String, num> destinations,
  }) = _PiForwardDestinationsModel;

  late final PiForwardDestinations entity = PiForwardDestinations(
      destinations: destinations.map<String, double>(
          (key, value) => MapEntry(key.split('|').first, value.toDouble())));

  factory PiForwardDestinationsModel.fromJson(Map<String, dynamic> json) =>
      _$PiForwardDestinationsModelFromJson(json);
}

@freezed
class PiQueriesOverTimeModel with _$PiQueriesOverTimeModel {
  PiQueriesOverTimeModel._();
  factory PiQueriesOverTimeModel({
    @JsonKey(name: 'domains_over_time')
        required Map<String, num> domainsOverTime,
    @JsonKey(name: 'ads_over_time') required Map<String, num> adsOverTime,
  }) = _PiQueriesOverTimeModel;

  late final PiQueriesOverTime entity = PiQueriesOverTime(
    domainsOverTime: domainsOverTime.map((key, value) => MapEntry(
        DateTime.fromMillisecondsSinceEpoch(int.parse(key) * 1000),
        value.toInt())),
    adsOverTime: adsOverTime.map((key, value) => MapEntry(
        DateTime.fromMillisecondsSinceEpoch(int.parse(key) * 1000),
        value.toInt())),
  );

  factory PiQueriesOverTimeModel.fromJson(Map<String, dynamic> json) =>
      _$PiQueriesOverTimeModelFromJson(json);
}
