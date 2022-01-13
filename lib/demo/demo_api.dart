import 'dart:async';
import 'dart:math';

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

  final List<QueryItem> _startItems = [
    ...List.generate(
        7, (index) => randomQueryItem(Duration(seconds: 30 + index * 130))),
    ...List.generate(
        7,
        (index) => randomQueryItem(
            Duration(days: 1 + index * index * index) + randomDayDuration()))
  ];

  List<QueryItem> _items = [];

  Future<void> _sleep(
      [Duration duration = const Duration(milliseconds: 500)]) async {
    // if (kDebugMode) return;
    await Future.delayed(duration +
        Duration(milliseconds: _random.nextInt(duration.inMilliseconds)));
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
  Future<PiholeStatus> sleep(Duration duration, _) async {
    await _sleep();
    final oldStatus = _status;
    scheduleMicrotask(() {
      Future.delayed(duration).then((_) {
        _status = oldStatus;
      });
    });
    return _setStatus(const PiholeStatus.disabled());
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
    await _sleep();
    return PiQueriesOverTime(
      domainsOverTime: {
        DateTime.fromMillisecondsSinceEpoch(1623071100 * 1000): 52,
        DateTime.fromMillisecondsSinceEpoch(1623071700 * 1000): 46,
        DateTime.fromMillisecondsSinceEpoch(1623072300 * 1000): 51,
      },
      adsOverTime: {
        DateTime.fromMillisecondsSinceEpoch(1623071100 * 1000): 11,
        DateTime.fromMillisecondsSinceEpoch(1623071700 * 1000): 10,
        DateTime.fromMillisecondsSinceEpoch(1623072300 * 1000): 12,
      },
    );
  }

  int count = 0;

  @override
  Future<List<QueryItem>> fetchQueryItems(_, int maxResults) async {
    await _sleep();
    count++;

    // throw PiholeApiFailure.emptyList();
    // return [];
    // if (count % 2 == 0) return _items;
    // if (count == 1) throw 'Nope';
    // return [];

    _items = [
      ...List.generate(_random.nextInt(2) + 1, (_) => randomQueryItem()),
      // ..._items,
      ..._startItems,
    ];

    return _items;
  }

  @override
  Future<PiQueryTypes> fetchQueryTypes(_) async {
    await _sleep();

    final ip4 = 10 + _random.nextInt(9) + _random.nextDouble();
    final ip6 = 15 + _random.nextInt(14) + _random.nextDouble();
    final srv = 25 + _random.nextInt(9) + _random.nextDouble();
    final ptr = 5 + _random.nextInt(9) + _random.nextDouble();
    final https = 100.0 - ip4 - ip6 - srv - ptr;

    return PiQueryTypes(types: {
      "A (IPv4)": ip4,
      "AAAA (IPv6)": ip6,
      "SRV": srv,
      "PTR": ptr,
      "HTTPS": https,
      "ANY": 0,
    });
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
    await _sleep();

    // count++;
    // if (count % 2 == 1) {
    //   throw PiholeApiFailure.general('Failure demonstration #$count');
    // }

    return PiVersions(
      hasCoreUpdate: false,
      hasWebUpdate: false,
      hasFtlUpdate: true,
      currentCoreVersion: 'v1.2.3',
      currentWebVersion: 'v5.8',
      currentFtlVersion: 'v2.3.1',
      latestCoreVersion: 'v1.2.3',
      latestWebVersion: 'v5.8',
      latestFtlVersion: 'v2.3.4',
      coreBranch: 'main',
      webBranch: 'main',
      ftlBranch: 'develop',
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
}
