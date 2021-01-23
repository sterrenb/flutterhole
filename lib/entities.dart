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
