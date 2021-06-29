import 'package:freezed_annotation/freezed_annotation.dart';

import 'entities.dart';
import 'formatting.dart';

part 'models.freezed.dart';
part 'models.g.dart';

@freezed
class PiSummaryModel with _$PiSummaryModel {
  PiSummaryModel._();

  factory PiSummaryModel({
    @JsonKey(fromJson: numFromJson, name: 'domains_being_blocked')
    @Default(0)
        num domainsBeingBlocked,
    @JsonKey(fromJson: numFromJson, name: 'dns_queries_today')
    @Default(0)
        num dnsQueriesToday,
    @JsonKey(fromJson: numFromJson, name: 'ads_blocked_today')
    @Default(0)
        num adsBlockedToday,
    @JsonKey(fromJson: numFromJson, name: 'ads_percentage_today')
    @Default(0)
        num adsPercentageToday,
    @JsonKey(fromJson: numFromJson, name: 'unique_domains')
    @Default(0)
        num uniqueDomains,
    @JsonKey(fromJson: numFromJson, name: 'queries_forwarded')
    @Default(0)
        num queriesForwarded,
    @JsonKey(fromJson: numFromJson, name: 'queries_cached')
    @Default(0)
        num queriesCached,
    @JsonKey(fromJson: numFromJson, name: 'clients_ever_seen')
    @Default(0)
        num clientsEverSeen,
    @JsonKey(fromJson: numFromJson, name: 'unique_clients')
    @Default(0)
        num uniqueClients,
    @JsonKey(fromJson: numFromJson, name: 'dns_queries_all_types')
    @Default(0)
        num dnsQueriesAllTypes,
    @JsonKey(fromJson: numFromJson, name: 'reply_NODATA')
    @Default(0)
        num replyNoData,
    @JsonKey(fromJson: numFromJson, name: 'reply_NXDOMAIN')
    @Default(0)
        num replyNxDomain,
    @JsonKey(fromJson: numFromJson, name: 'reply_CNAME')
    @Default(0)
        num replyCName,
    @JsonKey(fromJson: numFromJson, name: 'reply_IP') @Default(0) num replyIP,
    @JsonKey(fromJson: numFromJson, name: 'privacy_level')
    @Default(0)
        num privacyLevel,
    @JsonKey(name: 'status') @Default('unknown') String status,
  }) = _PiSummaryModel;

  factory PiSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$PiSummaryModelFromJson(json);

  late final PiSummary entity = PiSummary(
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
      destinations: destinations.map<String, double>((String key, num value) =>
          MapEntry(key.split('|').first, value.toDouble())));

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
    domainsOverTime: domainsOverTime.map(
        (key, value) => MapEntry(dateTimeFromPiholeString(key), value.toInt())),
    adsOverTime: adsOverTime.map(
        (key, value) => MapEntry(dateTimeFromPiholeString(key), value.toInt())),
  );

  factory PiQueriesOverTimeModel.fromJson(Map<String, dynamic> json) =>
      _$PiQueriesOverTimeModelFromJson(json);
}

// https://github.com/pi-hole/AdminLTE/blob/44aff727e59d129e6201341caa1d74c8b2954bd2/scripts/pi-hole/js/queries.js#L181
QueryStatus piStringToQueryStatus(String json) {
  try {
    final int index = int.parse(json);

    if (index > QueryStatus.values.length || index == 0)
      return QueryStatus.values.first;

    return QueryStatus.values[index];
  } catch (e) {
    return QueryStatus.Unknown;
  }
}

// https://github.com/pi-hole/AdminLTE/blob/44aff727e59d129e6201341caa1d74c8b2954bd2/scripts/pi-hole/js/queries.js#L158
DnsSecStatus piStringToDnsSecStatus(String json) {
  final int index = int.parse(json);

  if (index > DnsSecStatus.values.length || index == 0)
    return DnsSecStatus.values.first;

  return DnsSecStatus.values[index - 1];
}

@freezed
class QueryItemModel with _$QueryItemModel {
  QueryItemModel._();

  factory QueryItemModel({
    required DateTime timestamp,
    required String queryType,
    required String domain,
    required String clientName,
    required QueryStatus queryStatus,
    required DnsSecStatus dnsSecStatus,
    required double delta,
  }) = _QueryItemModel;

  factory QueryItemModel.fromList(List<dynamic> list) => QueryItemModel(
        timestamp: dateTimeFromPiholeString(list.elementAt(0)),
        queryType: list.elementAt(1),
        // queryType: _$enumDecodeNullable(_$QueryTypeEnumMap, list.elementAt(1)),
        domain: list.elementAt(2) as String,
        clientName: list.elementAt(3) as String,
        queryStatus: piStringToQueryStatus(list.elementAt(4)),
        dnsSecStatus: piStringToDnsSecStatus(list.elementAt(5)),
        delta: (double.tryParse(list.elementAt(7)) ?? 0.0) / 10,
      );

  factory QueryItemModel.fromJson(Map<String, dynamic> json) =>
      _$QueryItemModelFromJson(json);

  late final QueryItem entity = QueryItem(
    timestamp: timestamp,
    queryType: queryType,
    domain: domain,
    clientName: clientName,
    queryStatus: queryStatus,
    dnsSecStatus: dnsSecStatus,
    delta: delta,
  );
}

@freezed
class TopItemsModel with _$TopItemsModel {
  TopItemsModel._();

  factory TopItemsModel({
    @JsonKey(name: 'top_queries') required Map<String, int> topQueries,
    @JsonKey(name: 'top_ads') required Map<String, int> topAds,
  }) = _TopItemsModel;

  factory TopItemsModel.fromJson(Map<String, dynamic> json) =>
      _$TopItemsModelFromJson(json);

  late final TopItems entity = TopItems(
    topQueries: topQueries,
    topAds: topAds,
  );
}

@freezed
class PiClientNameModel with _$PiClientNameModel {
  PiClientNameModel._();

  factory PiClientNameModel({
    required String ip,
    String? name,
  }) = _PiClientNameModel;

  factory PiClientNameModel.fromJson(Map<String, dynamic> json) =>
      _$PiClientNameModelFromJson(json);

  late final PiClientName entity = PiClientName(ip: ip, name: name ?? '');
}

@freezed
class PiClientsOverTimeModel with _$PiClientsOverTimeModel {
  PiClientsOverTimeModel._();

  factory PiClientsOverTimeModel({
    required List<PiClientNameModel> clients,
    @JsonKey(name: 'over_time') required Map<String, List<int>> activity,
  }) = _PiClientsOverTimeModel;

  late final PiClientActivityOverTime entity = PiClientActivityOverTime(
    clients: clients.map((e) => e.entity).toList(),
    activity: activity.map((dateTimeString, hits) => MapEntry(
          dateTimeFromPiholeString(dateTimeString),
          hits,
        )),
  );

  factory PiClientsOverTimeModel.fromJson(Map<String, dynamic> json) =>
      _$PiClientsOverTimeModelFromJson(json);
}

@freezed
class PiVersionsModel with _$PiVersionsModel {
  PiVersionsModel._();

  factory PiVersionsModel({
    @JsonKey(name: 'core_update') required bool hasCoreUpdate,
    @JsonKey(name: 'web_update') required bool hasWebUpdate,
    @JsonKey(name: 'FTL_update') required bool hasFtlUpdate,
    @JsonKey(name: 'core_current') required String currentCoreVersion,
    @JsonKey(name: 'web_current') required String currentWebVersion,
    @JsonKey(name: 'FTL_current') required String currentFtlVersion,
    @JsonKey(name: 'core_latest') required String latestCoreVersion,
    @JsonKey(name: 'web_latest') required String latestWebVersion,
    @JsonKey(name: 'FTL_latest') required String latestFtlVersion,
    @JsonKey(name: 'core_branch') required String coreBranch,
    @JsonKey(name: 'web_branch') required String webBranch,
    @JsonKey(name: 'FTL_branch') required String ftlBranch,
  }) = _PiVersionsModel;

  factory PiVersionsModel.fromJson(Map<String, dynamic> json) =>
      _$PiVersionsModelFromJson(json);

  late final PiVersions entity = PiVersions(
    hasCoreUpdate: hasCoreUpdate,
    hasWebUpdate: hasWebUpdate,
    hasFtlUpdate: hasFtlUpdate,
    currentCoreVersion: currentCoreVersion,
    currentWebVersion: currentWebVersion,
    currentFtlVersion: currentFtlVersion,
    latestCoreVersion: latestCoreVersion,
    latestWebVersion: latestWebVersion,
    latestFtlVersion: latestFtlVersion,
    coreBranch: coreBranch,
    webBranch: webBranch,
    ftlBranch: ftlBranch,
  );
}
