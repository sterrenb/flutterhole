import 'dart:math';

import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'formatting.dart';

part 'entities.freezed.dart';

@freezed
class PiholeRepositoryParams with _$PiholeRepositoryParams {
  PiholeRepositoryParams._();

  factory PiholeRepositoryParams({
    required Dio dio,
    required String baseUrl,
    required bool useSsl,
    required String apiPath,
    required int apiPort,
    required bool apiTokenRequired,
    required String apiToken,
    required bool allowSelfSignedCertificates,
    required String adminHome,
  }) = _PiholeRepositoryParams;

  late final String dioBase =
      '${useSsl ? 'https://' : 'http://'}$baseUrl${(apiPort == 80 && useSsl == false) || (apiPort == 443 && useSsl == true) ? '' : ':$apiPort'}';
}

@freezed
class PiholeApiFailure with _$PiholeApiFailure {
  factory PiholeApiFailure.notFound() = _NotFound;

  const factory PiholeApiFailure.notAuthenticated() = _NotAuthenticated;

  const factory PiholeApiFailure.invalidResponse(int statusCode) =
      _InvalidResponse;

  const factory PiholeApiFailure.emptyString() = _EmptyString;

  const factory PiholeApiFailure.emptyList() = _EmptyList;

  const factory PiholeApiFailure.cancelled() = _Cancelled;

  const factory PiholeApiFailure.timeout() = _Timeout;

  const factory PiholeApiFailure.hostname() = _HostName;

  const factory PiholeApiFailure.general(String message) = _GeneralApiFailure;

  const factory PiholeApiFailure.unknown(dynamic e) = _UnknownApiFailure;
}

@freezed
class PiholeStatus with _$PiholeStatus {
  const factory PiholeStatus.loading() = PiholeStatusLoading;

  const factory PiholeStatus.enabled() = PiholeStatusEnabled;

  const factory PiholeStatus.disabled() = PiholeStatusDisabled;

  const factory PiholeStatus.sleeping(Duration duration, DateTime start) =
      PiholeStatusSleeping;

  const factory PiholeStatus.failure(PiholeApiFailure failure) =
      PiholeStatusFailure;
}

@freezed
class PiSummary with _$PiSummary {
  const factory PiSummary({
    required int domainsBeingBlocked,
    required int dnsQueriesToday,
    required int adsBlockedToday,
    required double adsPercentageToday,
    required int uniqueDomains,
    required int queriesForwarded,
    required int queriesCached,
    required int clientsEverSeen,
    required int uniqueClients,
    required int dnsQueriesAllTypes,
    required int replyNoData,
    required int replyNxDomain,
    required int replyCName,
    required int replyIP,
    required int privacyLevel,
    required PiholeStatus status,
  }) = _PiSummary;
}

@freezed
class PiDetails with _$PiDetails {
  PiDetails._();

  factory PiDetails({
    required double? temperature,
    required List<double> cpuLoads,
    required double? memoryUsage,
  }) = _PiDetails;

  late final String temperatureInCelcius =
      '${(temperature ?? -1).toStringAsFixed(1)} °C';

  late final String temperatureInFahrenheit =
      '${celciusToFahrenheit((temperature ?? -1)).toStringAsFixed(1)} °F';

  late final String temperatureInKelvin =
      '${celciusToKelvin((temperature ?? -1)).toStringAsFixed(1)} °K';
}

@freezed
class PiQueryTypes with _$PiQueryTypes {
  factory PiQueryTypes({required Map<String, double> types}) = _PiQueryTypes;
}

@freezed
class PiForwardDestinations with _$PiForwardDestinations {
  factory PiForwardDestinations({required Map<String, double> destinations}) =
      _PiForwardDestinations;
}

@freezed
class PiQueriesOverTime with _$PiQueriesOverTime {
  PiQueriesOverTime._();

  factory PiQueriesOverTime({
    required Map<DateTime, int> domainsOverTime,
    required Map<DateTime, int> adsOverTime,
  }) = _PiQueriesOverTime;

  late final int highestDomains = domainsOverTime.values.reduce(max);
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

@freezed
class QueryItem with _$QueryItem {
  QueryItem._();

  factory QueryItem({
    required DateTime timestamp,
    required String queryType,
    required String domain,
    required String clientName,
    required QueryStatus queryStatus,
    required DnsSecStatus dnsSecStatus,
    required double delta, // milliseconds
  }) = _QueryItem;

  late final int pageKey = (timestamp.millisecondsSinceEpoch / 1000).round();
}

@freezed
class TopItems with _$TopItems {
  TopItems._();

  factory TopItems({
    required Map<String, int> topQueries,
    required Map<String, int> topAds,
  }) = _TopItems;
}

@freezed
class SleepPiParams with _$SleepPiParams {
  factory SleepPiParams(PiholeRepositoryParams params, Duration duration) =
      _SleepPiParams;
}

@freezed
class PiClientName with _$PiClientName {
  PiClientName._();

  factory PiClientName({
    required String ip,
    required String name,
  }) = _PiClientName;
}

@freezed
class PiClientActivityOverTime with _$PiClientActivityOverTime {
  PiClientActivityOverTime._();

  factory PiClientActivityOverTime({
    required List<PiClientName> clients,
    required Map<DateTime, List<int>> activity,
  }) = _PiClientActivityOverTime;

  late final Map<PiClientName, List<int>> byClient = clients.asMap().map(
      (index, client) => MapEntry(
          client, activity.values.map((e) => e.elementAt(index)).toList()));
}

@freezed
class PiVersions with _$PiVersions {
  PiVersions._();

  factory PiVersions({
    required bool hasCoreUpdate,
    required bool hasWebUpdate,
    required bool hasFtlUpdate,
    required String currentCoreVersion,
    required String currentWebVersion,
    required String currentFtlVersion,
    required String latestCoreVersion,
    required String latestWebVersion,
    required String latestFtlVersion,
    required String coreBranch,
    required String webBranch,
    required String ftlBranch,
  }) = _PiVersions;
}
