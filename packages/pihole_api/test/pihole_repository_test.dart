import 'package:clock/clock.dart';
import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:pihole_api/pihole_api.dart';
import 'package:pihole_api/src/formatting.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() async {
  late PiholeRepositoryParams params;
  late Dio dio;
  late DioAdapter dioAdapter;
  late PiholeRepository repository;
  late CancelToken cancelToken;

  setUp(() {
    dio = Dio();
    dioAdapter = DioAdapter();
    dio.httpClientAdapter = dioAdapter;
    cancelToken = CancelToken();
    params = PiholeRepositoryParams(
      dio: dio,
      baseUrl: "pi.hole",
      useSsl: false,
      apiPath: "admin/api.php",
      apiPort: 80,
      apiTokenRequired: true,
      apiToken: "token",
      allowSelfSignedCertificates: false,
      adminHome: "/admin",
    );
    repository = PiholeRepository(params);
  });

  group('fetchSummary', () {
    test('fetchSummary returns PiSummary', () async {
      dioAdapter.onGet(
          "/admin/api.php",
          (request) => request.reply(200, {
                "domains_being_blocked": 80473,
                "dns_queries_today": 19000,
                "ads_blocked_today": 3,
                "ads_percentage_today": 30.572075,
                "unique_domains": 5,
                "queries_forwarded": 6,
                "queries_cached": 7,
                "clients_ever_seen": 8,
                "unique_clients": 9,
                "dns_queries_all_types": 1,
                "reply_NODATA": 2,
                "reply_NXDOMAIN": 3,
                "reply_CNAME": 4,
                "reply_IP": 5,
                "privacy_level": 6,
                "status": "enabled",
                "gravity_last_updated": {
                  "file_exists": true,
                  "absolute": 1624765511,
                  "relative": {"days": 2, "hours": 5, "minutes": 49}
                }
              }),
          queryParameters: {'summaryRaw': ''});
      final res = await repository.fetchSummary(cancelToken);
      expect(
          res,
          PiSummary(
            domainsBeingBlocked: 80473,
            dnsQueriesToday: 19000,
            adsBlockedToday: 3,
            adsPercentageToday: 30.572075,
            uniqueDomains: 5,
            queriesForwarded: 6,
            queriesCached: 7,
            clientsEverSeen: 8,
            uniqueClients: 9,
            dnsQueriesAllTypes: 1,
            replyNoData: 2,
            replyNxDomain: 3,
            replyCName: 4,
            replyIP: 5,
            privacyLevel: 6,
            status: PiholeStatus.enabled(),
          ));
    });

    test('fetchSummary handles empty reply', () async {
      dioAdapter.onGet("/admin/api.php", (request) => request.reply(200, ""),
          queryParameters: {'summaryRaw': ''});
      expect(repository.fetchSummary(cancelToken),
          throwsA(PiholeApiFailure.emptyString()));
    });

    test('fetchSummary handles DioError', () async {
      dioAdapter.onGet(
          "/admin/api.php",
          (request) => request.throws(
              400, DioError(requestOptions: RequestOptions(path: ""))),
          queryParameters: {'summaryRaw': ''});
      expect(repository.fetchSummary(cancelToken),
          throwsA(PiholeApiFailure.general("")));
    });

    test('fetchSummary handles failed host lookup', () async {
      dioAdapter.onGet(
          "/admin/api.php",
          (request) => request.throws(
              400,
              DioError(
                  requestOptions: RequestOptions(path: ""),
                  type: DioErrorType.other,
                  error: 'Failed host lookup')),
          queryParameters: {'summaryRaw': ''});
      expect(repository.fetchSummary(cancelToken),
          throwsA(PiholeApiFailure.hostname()));
    });

    test('fetchSummary handles timeout', () async {
      dioAdapter.onGet(
          "/admin/api.php",
          (request) => request.throws(
              400,
              DioError(
                  requestOptions: RequestOptions(path: ""),
                  type: DioErrorType.connectTimeout)),
          queryParameters: {'summaryRaw': ''});
      expect(repository.fetchSummary(cancelToken),
          throwsA(PiholeApiFailure.timeout()));
    });

    test('fetchSummary handles invalid response', () async {
      dioAdapter.onGet(
          "/admin/api.php",
          (request) => request.throws(
              500,
              DioError(
                  requestOptions: RequestOptions(path: ""),
                  type: DioErrorType.response)),
          queryParameters: {'summaryRaw': ''});
      expect(repository.fetchSummary(cancelToken),
          throwsA(PiholeApiFailure.invalidResponse(500)));
    });

    test('fetchSummary handles cancellation', () async {
      dioAdapter.onGet(
          "/admin/api.php",
          (request) => request.throws(
              400,
              DioError(
                  requestOptions: RequestOptions(path: ""),
                  type: DioErrorType.cancel)),
          queryParameters: {'summaryRaw': ''});
      expect(repository.fetchSummary(cancelToken),
          throwsA(PiholeApiFailure.cancelled()));
    });
  });

  group('fetchQueryTypes', () {
    test('fetchQueryTypes returns PiQueryTypes', () async {
      dioAdapter.onGet(
          "/admin/api.php",
          (request) => request.reply(200, {
                "querytypes": {
                  "A (IPv4)": 93.18,
                  "AAAA (IPv6)": 1.79,
                  "ANY": 0,
                  "SRV": 0.99,
                  "SOA": 0.03,
                  "PTR": 1.29,
                  "TXT": 0,
                  "NAPTR": 0,
                  "MX": 0,
                  "DS": 0,
                  "RRSIG": 0,
                  "DNSKEY": 0,
                  "NS": 0.02,
                  "OTHER": 0,
                  "SVCB": 0,
                  "HTTPS": 2.7
                }
              }),
          queryParameters: {'getQueryTypes': '', 'auth': 'token'});
      final res = await repository.fetchQueryTypes(cancelToken);
      expect(
          res,
          PiQueryTypes(types: {
            "A (IPv4)": 93.18,
            "AAAA (IPv6)": 1.79,
            "SRV": 0.99,
            "SOA": 0.03,
            "PTR": 1.29,
            "NS": 0.02,
            "HTTPS": 2.7
          }));
    });

    test('fetchQueryTypes handles empty list response', () async {
      dioAdapter.onGet("/admin/api.php", (request) => request.reply(200, []),
          queryParameters: {'getQueryTypes': '', 'auth': 'token'});
      expect(repository.fetchQueryTypes(cancelToken),
          throwsA(PiholeApiFailure.emptyList()));
    });

    test('fetchQueryTypes handles unauthenticated', () async {
      repository = PiholeRepository(params.copyWith(apiToken: ""));
      dioAdapter.onGet("/admin/api.php", (request) => request.reply(200, []),
          queryParameters: {'getQueryTypes': '', 'auth': ''});
      expect(repository.fetchQueryTypes(cancelToken),
          throwsA(PiholeApiFailure.notAuthenticated()));
    });

    test('fetchQueryTypes handles DioError', () async {
      dioAdapter.onGet(
          "/admin/api.php",
          (request) => request.throws(
              400, DioError(requestOptions: RequestOptions(path: ""))),
          queryParameters: {'getQueryTypes': '', 'auth': 'token'});
      expect(repository.fetchQueryTypes(cancelToken),
          throwsA(PiholeApiFailure.general("")));
    });
  });

  group('fetchForwardDestinations', () {
    test('fetchForwardDestinations returns PiForwardDestinations', () async {
      dioAdapter.onGet(
          "/admin/api.php",
          (request) => request.reply(200, {
                "forward_destinations": {
                  "blocklist|blocklist": 29.83,
                  "cache|cache": 5.49,
                  "resolver2.opendns.com#53|208.67.220.220#53": 42.46,
                  "resolver1.opendns.com#53|208.67.222.222#53": 24.8
                }
              }),
          queryParameters: {'getForwardDestinations': '', 'auth': 'token'});
      final res = await repository.fetchForwardDestinations(cancelToken);
      expect(
          res,
          PiForwardDestinations(
            destinations: {
              "blocklist": 29.83,
              "cache": 5.49,
              "resolver2.opendns.com#53": 42.46,
              "resolver1.opendns.com#53": 24.8
            },
          ));
    });

    test('fetchForwardDestinations handles DioError', () async {
      dioAdapter.onGet(
          "/admin/api.php",
          (request) => request.throws(
              400, DioError(requestOptions: RequestOptions(path: ""))),
          queryParameters: {'getForwardDestinations': '', 'auth': 'token'});
      expect(repository.fetchForwardDestinations(cancelToken),
          throwsA(PiholeApiFailure.general("")));
    });
  });

  group('fetchQueriesOverTime', () {
    test('fetchQueriesOverTime returns PiQueriesOverTime', () async {
      dioAdapter.onGet(
          "/admin/api.php",
          (request) => request.reply(200, {
                "domains_over_time": {
                  "1623071100": 52,
                  "1623071700": 46,
                  "1623072300": 51
                },
                "ads_over_time": {
                  "1623071100": 11,
                  "1623071700": 10,
                  "1623072300": 12
                }
              }),
          queryParameters: {'overTimeData10mins': '', 'auth': 'token'});
      final res = await repository.fetchQueriesOverTime(cancelToken);
      expect(
          res,
          PiQueriesOverTime(
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
          ));
    });

    test('fetchQueriesOverTime handles DioError', () async {
      dioAdapter.onGet(
          "/admin/api.php",
          (request) => request.throws(
              400, DioError(requestOptions: RequestOptions(path: ""))),
          queryParameters: {'overTimeData10mins': '', 'auth': 'token'});
      expect(repository.fetchQueriesOverTime(cancelToken),
          throwsA(PiholeApiFailure.general("")));
    });
  });

  group('fetchClientActivityOverTime', () {
    test('fetchClientActivityOverTime returns PiClientActivityOverTime',
        () async {
      dioAdapter.onGet(
          "/admin/api.php",
          (request) => request.reply(200, {
                "clients": [
                  {"name": "localhost", "ip": "127.0.0.1"},
                  {"name": "", "ip": "10.0.1.2"},
                  {"name": "", "ip": "10.0.1.10"}
                ],
                "over_time": {
                  "1623071100": [0, 26, 0, 0, 4, 0, 22, 0],
                  "1623071700": [0, 25, 0, 0, 0, 0, 21, 0],
                  "1623072300": [0, 32, 0, 0, 0, 0, 19, 0]
                }
              }),
          queryParameters: {
            'getClientNames': '',
            'overTimeDataClients': '',
            'auth': 'token'
          });
      final res = await repository.fetchClientActivityOverTime(cancelToken);
      expect(
          res,
          PiClientActivityOverTime(
            clients: [
              PiClientName(ip: "127.0.0.1", name: "localhost"),
              PiClientName(ip: "10.0.1.2", name: ""),
              PiClientName(ip: "10.0.1.10", name: ""),
            ],
            activity: {
              DateTime.fromMillisecondsSinceEpoch(1623071100 * 1000): [
                0,
                26,
                0,
                0,
                4,
                0,
                22,
                0
              ],
              DateTime.fromMillisecondsSinceEpoch(1623071700 * 1000): [
                0,
                25,
                0,
                0,
                0,
                0,
                21,
                0
              ],
              DateTime.fromMillisecondsSinceEpoch(1623072300 * 1000): [
                0,
                32,
                0,
                0,
                0,
                0,
                19,
                0
              ],
            },
          ));
    });

    test('fetchClientActivityOverTime handles DioError', () async {
      dioAdapter.onGet(
          "/admin/api.php",
          (request) => request.throws(
              400, DioError(requestOptions: RequestOptions(path: ""))),
          queryParameters: {
            'getClientNames': '',
            'overTimeDataClients': '',
            'auth': 'token'
          });
      expect(repository.fetchClientActivityOverTime(cancelToken),
          throwsA(PiholeApiFailure.general("")));
    });
  });

  group('ping', () {
    test('ping returns PiholeStatus', () async {
      dioAdapter.onGet("/admin/api.php",
          (request) => request.reply(200, {"status": "enabled"}),
          queryParameters: {'status': ''});
      final res = await repository.ping(cancelToken);
      expect(res, PiholeStatus.enabled());
    });

    test('ping handles DioError', () async {
      dioAdapter.onGet(
          "/admin/api.php",
          (request) => request.throws(
              400, DioError(requestOptions: RequestOptions(path: ""))),
          queryParameters: {'status': ''});
      expect(
          repository.ping(cancelToken), throwsA(PiholeApiFailure.general("")));
    });
  });

  group('enable', () {
    test('enable returns PiholeStatus', () async {
      dioAdapter.onGet("/admin/api.php",
          (request) => request.reply(200, {"status": "enabled"}),
          queryParameters: {'enable': '', 'auth': 'token'});
      final res = await repository.enable(cancelToken);
      expect(res, PiholeStatus.enabled());
    });

    test('enable handles DioError', () async {
      dioAdapter.onGet(
          "/admin/api.php",
          (request) => request.throws(
              400, DioError(requestOptions: RequestOptions(path: ""))),
          queryParameters: {'enable': '', 'auth': 'token'});
      expect(repository.enable(cancelToken),
          throwsA(PiholeApiFailure.general("")));
    });
  });

  group('disable', () {
    test('disable returns PiholeStatus', () async {
      dioAdapter.onGet("/admin/api.php",
          (request) => request.reply(200, {"status": "disabled"}),
          queryParameters: {'disable': '', 'auth': 'token'});
      final res = await repository.disable(cancelToken);
      expect(res, PiholeStatus.disabled());
    });

    test('disable handles DioError', () async {
      dioAdapter.onGet(
          "/admin/api.php",
          (request) => request.throws(
              400, DioError(requestOptions: RequestOptions(path: ""))),
          queryParameters: {'disable': '', 'auth': 'token'});
      expect(repository.disable(cancelToken),
          throwsA(PiholeApiFailure.general("")));
    });
  });

  group('sleep', () {
    test('sleep returns PiholeStatus', () async {
      dioAdapter.onGet("/admin/api.php",
          (request) => request.reply(200, {"status": "disabled"}),
          queryParameters: {'disable': '30', 'auth': 'token'});
      withClock(Clock.fixed(DateTime(2000)), () async {
        final res = await repository.sleep(Duration(seconds: 30), cancelToken);
        expect(res, PiholeStatus.sleeping(Duration(seconds: 30), clock.now()));
      });
    });

    test('sleep returns PiholeStatus.enabled when sleep fails', () async {
      dioAdapter.onGet("/admin/api.php",
          (request) => request.reply(200, {"status": "enabled"}),
          queryParameters: {'disable': '30', 'auth': 'token'});
      final res = await repository.sleep(Duration(seconds: 30), cancelToken);
      expect(res, PiholeStatus.enabled());
    });

    test('sleep handles DioError', () async {
      dioAdapter.onGet(
          "/admin/api.php",
          (request) => request.throws(
              400, DioError(requestOptions: RequestOptions(path: ""))),
          queryParameters: {'disable': '60', 'auth': 'token'});
      expect(repository.sleep(Duration(seconds: 60), cancelToken),
          throwsA(PiholeApiFailure.general("")));
    });
  });

  group('fetchQueryItems', () {
    test('fetchQueryItems returns List<QueryItem>', () async {
      dioAdapter.onGet(
          "/admin/api.php",
          (request) => request.reply(200, {
                "data": [
                  [
                    "1624981977",
                    "A",
                    "example3.org",
                    "10.0.1.5",
                    "1",
                    "0",
                    "2",
                    "233",
                    "N\/A",
                    "-1",
                    "resolver2.opendns.com#53"
                  ],
                  [
                    "1624981977",
                    "HTTPS",
                    "example2.net",
                    "10.0.1.3",
                    "2",
                    "0",
                    "3",
                    "229",
                    "N\/A",
                    "-1",
                    "resolver2.opendns.com#52"
                  ],
                  [
                    "1624981977",
                    "A",
                    "example1.com",
                    "10.0.1.2",
                    "5",
                    "4",
                    "3",
                    "104",
                    "N\/A",
                    "-1",
                    "resolver2.opendns.com#51"
                  ],
                ]
              }),
          queryParameters: {'getAllQueries': '3', 'auth': 'token'});
      final res = await repository.fetchQueryItems(cancelToken, 3);
      expect(res, [
        QueryItem(
          timestamp: DateTime.fromMillisecondsSinceEpoch(1624981977 * 1000),
          queryType: "A",
          domain: "example1.com",
          clientName: "10.0.1.2",
          queryStatus: QueryStatus.BlockedWithBlacklist,
          dnsSecStatus: DnsSecStatus.Bogus,
          delta: 10.4,
        ),
        QueryItem(
          timestamp: DateTime.fromMillisecondsSinceEpoch(1624981977 * 1000),
          queryType: "HTTPS",
          domain: "example2.net",
          clientName: "10.0.1.3",
          queryStatus: QueryStatus.Forwarded,
          dnsSecStatus: DnsSecStatus.Empty,
          delta: 22.9,
        ),
        QueryItem(
          timestamp: DateTime.fromMillisecondsSinceEpoch(1624981977 * 1000),
          queryType: "A",
          domain: "example3.org",
          clientName: "10.0.1.5",
          queryStatus: QueryStatus.BlockedWithGravity,
          dnsSecStatus: DnsSecStatus.Empty,
          delta: 23.3,
        ),
      ]);
    });

    test('fetchQueryItems handles DioError', () async {
      dioAdapter.onGet(
          "/admin/api.php",
          (request) => request.throws(
              400, DioError(requestOptions: RequestOptions(path: ""))),
          queryParameters: {'getAllQueries': '10', 'auth': 'token'});
      expect(repository.fetchQueryItems(cancelToken, 10),
          throwsA(PiholeApiFailure.general("")));
    });
  });

  group('fetchTopItems', () {
    test('fetchTopItems returns TopItems', () async {
      dioAdapter.onGet(
          "/admin/api.php",
          (request) => request.reply(200, {
                "top_queries": {
                  "favorite.com": 340,
                  "great.org": 338,
                  "github.com": 260
                },
                "top_ads": {
                  "microsoft.com": 1082,
                  "googleadservices.com": 559,
                  "app-measurement.com": 539
                }
              }),
          queryParameters: {'topItems': '', 'auth': 'token'});
      final res = await repository.fetchTopItems(cancelToken);
      expect(
          res,
          TopItems(
            topQueries: {
              "favorite.com": 340,
              "great.org": 338,
              "github.com": 260
            },
            topAds: {
              "microsoft.com": 1082,
              "googleadservices.com": 559,
              "app-measurement.com": 539
            },
          ));
    });

    test('fetchTopItems handles DioError', () async {
      dioAdapter.onGet(
          "/admin/api.php",
          (request) => request.throws(
              400, DioError(requestOptions: RequestOptions(path: ""))),
          queryParameters: {'topItems': '', 'auth': 'token'});
      expect(repository.fetchTopItems(cancelToken),
          throwsA(PiholeApiFailure.general("")));
    });
  });

  group('fetchVersions', () {
    test('fetchVersions returns PiVersions', () async {
      dioAdapter.onGet(
          "/admin/api.php",
          (request) => request.reply(200, {
                "core_update": true,
                "web_update": true,
                "FTL_update": false,
                "core_current": "v5.2.4",
                "web_current": "v5.3.2",
                "FTL_current": "v5.6",
                "core_latest": "v5.3.1",
                "web_latest": "v5.5",
                "FTL_latest": "v5.6",
                "core_branch": "master",
                "web_branch": "master",
                "FTL_branch": "master"
              }),
          queryParameters: {'versions': ''});
      final res = await repository.fetchVersions(cancelToken);
      expect(
          res,
          PiVersions(
            hasCoreUpdate: true,
            hasWebUpdate: true,
            hasFtlUpdate: false,
            currentCoreVersion: "v5.2.4",
            currentWebVersion: "v5.3.2",
            currentFtlVersion: "v5.6",
            latestCoreVersion: "v5.3.1",
            latestWebVersion: "v5.5",
            latestFtlVersion: "v5.6",
            coreBranch: "master",
            webBranch: "master",
            ftlBranch: "master",
          ));
    });

    test('fetchVersions handles DioError', () async {
      dioAdapter.onGet(
          "/admin/api.php",
          (request) => request.throws(
              400, DioError(requestOptions: RequestOptions(path: ""))),
          queryParameters: {'versions': ''});
      expect(repository.fetchVersions(cancelToken),
          throwsA(PiholeApiFailure.general("")));
    });
  });

  group('fetchPiDetails', () {
    test('fetchPiDetails returns PiDetails', () async {
      dioAdapter.onGet(
        "/admin",
        (request) => request.reply(200, adminHtmlString),
      );
      final res = await repository.fetchPiDetails(cancelToken);
      expect(
          res,
          PiDetails(
            temperature: 48.312,
            cpuLoads: [],
            memoryUsage: 21.4,
          ));
    });

    test('fetchPiDetails handles empty string', () async {
      dioAdapter.onGet(
        "/admin",
        (request) => request.reply(200, ''),
      );
      expect(repository.fetchPiDetails(cancelToken),
          throwsA(PiholeApiFailure.emptyString()));
    });

    test('fetchPiDetails handles DioError', () async {
      dioAdapter.onGet(
          "/admin",
          (request) => request.throws(
              400, DioError(requestOptions: RequestOptions(path: ""))));
      expect(repository.fetchPiDetails(cancelToken),
          throwsA(PiholeApiFailure.general("")));
    });

    test('fetchPiDetails handles missing tags', () async {
      dioAdapter.onGet(
        "/admin",
        (request) => request.reply(200, adminHtmlStringWithoutTags),
      );
      final res = await repository.fetchPiDetails(cancelToken);
      expect(
          res,
          PiDetails(
            temperature: -1,
            cpuLoads: [],
            memoryUsage: -1,
          ));
    });
  });

  group('formatting', () {
    test('temperature', () {
      expect(celciusToKelvin(100), 373.15);
      expect(celciusToFahrenheit(100), 212);
    });
  });
}
