import 'dart:math';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'entities.freezed.dart';

@freezed
class Pi with _$Pi {
  Pi._();

  factory Pi({
    // annotation
    required int id,
    required String title,
    required String description,
    required Color primaryColor,
    required Color accentColor,
    required DashboardSettings dashboardSettings,

    // host details
    required String baseUrl,
    required bool useSsl,
    required String apiPath,
    required int apiPort,

    // authentication
    required String apiToken,
    required bool apiTokenRequired,
    required bool allowSelfSignedCertificates,
    required String basicAuthenticationUsername,
    required String basicAuthenticationPassword,

    // proxy
    required String proxyUrl,
    required int proxyPort,
  }) = _Pi;

  factory Pi.initial() => Pi(
        id: 0,
        title: "Pi-hole",
        description: "",
        primaryColor: Colors.purple,
        accentColor: Colors.orangeAccent,
        dashboardSettings: DashboardSettings.initial(),
        baseUrl: "pi.hole",
        useSsl: false,
        apiPath: "/admin/api.php",
        apiPort: 80,
        apiToken:
            "3f4fa74468f336df5c4cf1d343d160f8948375732f82ea1a057138ae7d35055c",
        apiTokenRequired: true,
        allowSelfSignedCertificates: false,
        basicAuthenticationUsername: "",
        basicAuthenticationPassword: "",
        proxyUrl: "",
        proxyPort: 8080,
      );

  late final String host = '$baseUrl:$apiPort';

  late final String baseApiUrl =
      '${useSsl ? 'https://' : 'http://'}$host$apiPath';

  late final String adminHome = '${useSsl ? 'https://' : 'http://'}$host/admin';
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

double _celciusToKelvin(double temp) => temp + 273.15;

double _celciusToFahrenheit(double temp) => (temp * (9 / 5)) + 32;

@freezed
class PiDetails with _$PiDetails {
  PiDetails._();

  factory PiDetails({
    required double temperature,
    required List<double> cpuLoads,
    required double memoryUsage,
  }) = _PiDetails;

  late final String temperatureInCelcius =
      '${temperature.toStringAsFixed(1)} °C';

  late final String temperatureInFahrenheit =
      '${_celciusToFahrenheit(temperature).toStringAsFixed(1)} °F';

  late final String temperatureInKelvin =
      '${_celciusToKelvin(temperature).toStringAsFixed(1)} °K';
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
  factory SleepPiParams(Pi pi, Duration duration) = _SleepPiParams;
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

enum DashboardID {
  SelectTiles,
  TotalQueries,
  QueriesBlocked,
  PercentBlocked,
  DomainsOnBlocklist,
  QueriesBarChart,
  ClientActivityBarChart,
  Temperature,
  Memory,
  QueryTypes,
  ForwardDestinations,
  TopPermittedDomains,
  TopBlockedDomains,
  Versions,
}

@freezed
class SettingsState with _$SettingsState {
  SettingsState._();

  factory SettingsState({
    required List<Pi> allPis,
    required int activeId,
    required bool dev,
  }) = _SettingsState;

  late final Pi active = allPis.firstWhere((element) {
    print("${element.id} == $activeId");
    return element.id == activeId;
  });
}

@freezed
class DashboardEntry with _$DashboardEntry {
  DashboardEntry._();

  factory DashboardEntry({
    required DashboardID id,
    required bool enabled,
  }) = _DashboardEntry;
}

@freezed
class DashboardSettings with _$DashboardSettings {
  DashboardSettings._();

  factory DashboardSettings({
    required List<DashboardEntry> entries,
  }) = _DashboardSettings;

  factory DashboardSettings.initial() => DashboardSettings(entries: [
        ...DashboardID.values
            .map<DashboardEntry>((e) => DashboardEntry(id: e, enabled: true))
            .toList()
            .sublist(0, DashboardID.values.length ~/ 2),
        DashboardEntry(id: DashboardID.SelectTiles, enabled: true),
      ]);

  late final List<DashboardID> keys = entries.map((e) => e.id).toList();
}
