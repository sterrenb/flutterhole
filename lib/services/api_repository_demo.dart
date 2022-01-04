import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:pihole_api/pihole_api.dart';

class PiholeRepositoryDemo implements PiholeRepository {
  PiholeRepositoryDemo(this.params) {
    debugPrint('making demo repository');
  }

  final PiholeRepositoryParams params;
  final _random = Random();

  PiholeStatus _status = const PiholeStatus.enabled();
  int dnsQueriesToday = 10000;
  int adsBlockedToday = 5600;
  int domainsBeingBlocked = 999894;

  Future<void> _sleep(
      [Duration duration = const Duration(milliseconds: 200)]) async {
    await Future.delayed(duration);
  }

  PiholeStatus _setStatus(PiholeStatus status) {
    _status = status;
    return status;
  }

  @override
  Future<PiholeStatus> disable(_) async {
    await _sleep();
    return _setStatus(const PiholeStatus.disabled());
  }

  @override
  Future<PiholeStatus> enable(_) async {
    await _sleep();
    return _setStatus(const PiholeStatus.enabled());
  }

  @override
  Future<PiClientActivityOverTime> fetchClientActivityOverTime(_) {
    // TODO: implement fetchClientActivityOverTime
    throw UnimplementedError();
  }

  @override
  Future<PiForwardDestinations> fetchForwardDestinations(_) async {
    await _sleep();

    if (params.apiTokenRequired && params.apiToken.isEmpty) {
      throw const PiholeApiFailure.notAuthenticated();
    }

    return PiForwardDestinations(destinations: {
      "blocklist|blocklist": 7.27,
      "cache|cache": 2.26,
      "dns.opendns.com#53|208.67.222.222#53": 54.11,
      "dns.opendns.com#53|208.67.220.220#53": 36.35,
    });
  }

  @override
  Future<PiDetails> fetchPiDetails(_) async {
    // TODO: implement fetchPiDetails
    throw UnimplementedError();
  }

  @override
  Future<PiQueriesOverTime> fetchQueriesOverTime(_) async {
    // TODO: implement fetchQueriesOverTime
    throw UnimplementedError();
  }

  @override
  Future<List<QueryItem>> fetchQueryItems(_, int maxResults) {
    // TODO: implement fetchQueryItems
    throw UnimplementedError();
  }

  @override
  Future<PiQueryTypes> fetchQueryTypes(_) async {
    // TODO: implement fetchQueryTypes
    throw UnimplementedError();
  }

  @override
  Future<PiSummary> fetchSummary(_) async {
    await _sleep();

    dnsQueriesToday += _random.nextInt(10);
    adsBlockedToday += _random.nextInt(20);
    domainsBeingBlocked += _random.nextInt(50);

    return PiSummary(
      domainsBeingBlocked: domainsBeingBlocked,
      dnsQueriesToday: dnsQueriesToday,
      adsBlockedToday: adsBlockedToday,
      adsPercentageToday: (adsBlockedToday / dnsQueriesToday) * 100,
      uniqueDomains: 5,
      queriesForwarded: 6,
      queriesCached: 7,
      clientsEverSeen: 8,
      uniqueClients: 9,
      dnsQueriesAllTypes: 10,
      replyNoData: 11,
      replyNxDomain: 12,
      replyCName: 13,
      replyIP: 14,
      privacyLevel: 15,
      status: _status,
    );
  }

  @override
  Future<TopItems> fetchTopItems(_) async {
    // TODO: implement fetchTopItems
    throw UnimplementedError();
  }

  @override
  Future<PiVersions> fetchVersions(_) async {
    // TODO: implement fetchVersions
    throw UnimplementedError();
  }

  @override
  Future<PiholeStatus> ping(_) async {
    await _sleep();

    if (params.apiPath != '/admin/api.php') {
      throw const PiholeApiFailure.general(
          'The API path should be "/admin/api.php"');
    }

    return _status;
  }

  @override
  Future<PiholeStatus> sleep(Duration duration, _) {
    // TODO: implement sleep
    throw UnimplementedError();
  }
}
