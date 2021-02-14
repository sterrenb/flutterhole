import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'entities.freezed.dart';

@freezed
abstract class Pi with _$Pi {
  factory Pi({
    // annotation
    @required String title,
    @required String description,
    @required Color primaryColor,

    // host details
    @required String baseUrl,
    @required String apiPath,
    @required int apiPort,

    // authentication
    @required String apiToken,
    @required bool apiTokenRequired,
    @required bool allowSelfSignedCertificates,
    @required String basicAuthenticationUsername,
    @required String basicAuthenticationPassword,

    // proxy
    @required String proxyUrl,
    @required int proxyPort,
  }) = _Pi;

  @late
  String get host => '$baseUrl:$apiPort';

  @late
  String get baseApiUrl => '$host/$apiPath';

  @late
  String get adminHome => '$host/admin';
}

@freezed
abstract class PiholeApiFailure with _$PiholeApiFailure {
  factory PiholeApiFailure.notFound() = _NotFound;

  const factory PiholeApiFailure.notAuthenticated() = _NotAuthenticated;

  const factory PiholeApiFailure.invalidResponse(int statusCode) =
      _InvalidResponse;

  const factory PiholeApiFailure.emptyString() = _EmptyString;

  const factory PiholeApiFailure.emptyList() = _EmptyList;

  const factory PiholeApiFailure.cancelled() = _Cancelled;

  const factory PiholeApiFailure.timeout() = _Timeout;

  const factory PiholeApiFailure.unknown(dynamic e) = _Unknown;

// @override
// String toString() => this.when(
//       notFound: () => 'Not found',
//       notAuthenticated: () => 'Not authenticated',
//       invalidResponse: (statusCode) => 'Invalid response ($statusCode)',
//       emptyString: () => 'Empty string',
//       emptyList: () => 'Empty list',
//       cancelled: () => 'Cancelled',
//       timeout: () => 'Timeout',
//       unknown: (error) => 'Unknown',
//     );
}

enum PiStatus {
  enabled,
  disabled,
}

@freezed
abstract class Summary with _$Summary {
  const factory Summary({
    @required int domainsBeingBlocked,
    @required int dnsQueriesToday,
    @required int adsBlockedToday,
    @required double adsPercentageToday,
    @required int uniqueDomains,
    @required int queriesForwarded,
    @required int queriesCached,
    @required int clientsEverSeen,
    @required int uniqueClients,
    @required int dnsQueriesAllTypes,
    @required int replyNoData,
    @required int replyNxDomain,
    @required int replyCName,
    @required int replyIP,
    @required int privacyLevel,
    @required PiStatus status,
  }) = _Summary;
}

double _celciusToKelvin(double temp) => temp + 273.15;

double _celciusToFahrenheit(double temp) => (temp * (9 / 5)) + 32;

@freezed
abstract class PiDetails with _$PiDetails {
  factory PiDetails({
    @required double temperature,
    @required List<double> cpuLoads,
    @required double memoryUsage,
  }) = _PiDetails;

  @late
  String get temperatureInCelcius => '${temperature.toStringAsFixed(1)} °C';

  @late
  String get temperatureInFahrenheit =>
      '${_celciusToFahrenheit(temperature).toStringAsFixed(1)} °F';

  @late
  String get temperatureInKelvin =>
      '${_celciusToKelvin(temperature).toStringAsFixed(1)} °K';
}

@freezed
abstract class PiQueryTypes with _$PiQueryTypes {
  factory PiQueryTypes({@required Map<String, double> types}) = _PiQueryTypes;
}

@freezed
abstract class PiForwardDestinations with _$PiForwardDestinations {
  factory PiForwardDestinations({@required Map<String, double> destinations}) =
      _PiForwardDestinations;
}

@freezed
abstract class PiQueriesOverTime with _$PiQueriesOverTime {
  factory PiQueriesOverTime({
   @required Map<DateTime, int> domainsOverTime,
   @required Map<DateTime, int> adsOverTime,
  }) = _PiQueriesOverTime;
}

