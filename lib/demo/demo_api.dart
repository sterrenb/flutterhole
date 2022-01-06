import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:pihole_api/pihole_api.dart';

import 'demo_generators.dart';

final _random = Random();

class DemoApi implements PiholeRepository {
  DemoApi(this.params);

  final PiholeRepositoryParams params;

  PiholeStatus _status = const PiholeStatus.enabled();
  int dnsQueriesToday = 10000;
  int adsBlockedToday = 5600;
  int domainsBeingBlocked = 999894;
  List<QueryItem> _items = [
    ...List.generate(
        10, (index) => randomQueryItem(Duration(seconds: 30 + index * 130))),
    ...List.generate(
        10,
        (index) => randomQueryItem(
            Duration(days: 1 + index * index * index) + randomDayDuration()))
  ];

  Future<void> _sleep(
      [Duration duration = const Duration(milliseconds: 400)]) async {
    if (kDebugMode) return;
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

    final google = 25 + _random.nextInt(24) + _random.nextDouble();
    final cache = 10 + _random.nextInt(4) + _random.nextDouble();
    final cloudflare = 30 + _random.nextInt(4) + _random.nextDouble();
    final blocklist = 100.0 - google - cache - cloudflare;

    return PiForwardDestinations(destinations: {
      'google': google,
      'cache': cache,
      'cloudflare': cloudflare,
      'blocklist': blocklist,
    });
  }

  @override
  Future<PiDetails> fetchPiDetails(_) async {
    await _sleep();
    return PiDetails(
        temperature: _random.nextDouble() * 5 + 45,
        cpuLoads: [],
        memoryUsage: _random.nextDouble() * 50 + 10);
  }

  @override
  Future<PiQueriesOverTime> fetchQueriesOverTime(_) async {
    // TODO: implement fetchQueriesOverTime
    throw UnimplementedError();
  }

  int count = 0;
  @override
  Future<List<QueryItem>> fetchQueryItems(_, int maxResults) async {
    await _sleep();

    _items = [
      ...List.generate(1, (_) => randomQueryItem()),
      ..._items,
    ];
    return _items;
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
    await _sleep(const Duration(seconds: 1));
    count++;
    if (count % 2 == 0) {
      throw PiholeApiFailure.general('Failure demonstration #$count');
    }

    return PiVersions(
      hasCoreUpdate: false,
      hasWebUpdate: false,
      hasFtlUpdate: true,
      currentCoreVersion: 'v1.2.3',
      currentWebVersion: 'v5.8',
      currentFtlVersion: 'v1.2.3',
      latestCoreVersion: 'v1.2.3',
      latestWebVersion: 'v5.8',
      latestFtlVersion: 'v1.3.4',
      coreBranch: 'master',
      webBranch: 'develop',
      ftlBranch: 'master',
    );
  }

  @override
  Future<PiholeStatus> ping(_) async {
    await _sleep();

    if (params.apiPath != '/admin/api.php') {
      throw const PiholeApiFailure.general(
          'Demo Failure: The API path should be "/admin/api.php"');
    }

    return _status;
  }

  @override
  Future<PiholeStatus> sleep(Duration duration, _) {
    // TODO: implement sleep
    throw UnimplementedError();
  }
}
