import 'package:http_mock_adapter/http_mock_adapter.dart';

import '../lib/src/fixtures.dart';

const _apiPath = '/admin/api.php';
const _adminPath = '/admin';

const _summary = {
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
};

const _queryTypes = {
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
};
const _forwardDestinations = {
  "forward_destinations": {
    "blocklist|blocklist": 29.83,
    "cache|cache": 5.49,
    "resolver2.opendns.com#53|208.67.220.220#53": 42.46,
    "resolver1.opendns.com#53|208.67.222.222#53": 24.8
  }
};
const _queriesOverTime = {
  "domains_over_time": {"1623071100": 52, "1623071700": 46, "1623072300": 51},
  "ads_over_time": {"1623071100": 11, "1623071700": 10, "1623072300": 12}
};
const _clientActivityOvertime = {
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
};
const _status = {"status": "enabled"};
const _queryItems = {
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
};
const _topItems = {
  "top_queries": {"favorite.com": 340, "great.org": 338, "github.com": 260},
  "top_ads": {
    "microsoft.com": 1082,
    "googleadservices.com": 559,
    "app-measurement.com": 539
  }
};
const _versions = {
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
};

/// Creates a [DioAdapter] that mocks all HTTP responses.
DioAdapter createMockDioAdapter() {
  final dio = DioAdapter();

  dio.onGet(
    _apiPath,
    (request) => request.reply(200, _summary),
    queryParameters: {'summaryRaw': ''},
  );

  dio.onGet(
    _apiPath,
    (request) => request.reply(200, _queryTypes),
    queryParameters: {'getQueryTypes': '', 'auth': 'token'},
  );
  dio.onGet(
    _apiPath,
    (request) => request.reply(200, _forwardDestinations),
    queryParameters: {'getForwardDestinations': '', 'auth': 'token'},
  );
  dio.onGet(
    _apiPath,
    (request) => request.reply(200, _queriesOverTime),
    queryParameters: {'overTimeData10mins': '', 'auth': 'token'},
  );
  dio.onGet(
    _apiPath,
    (request) => request.reply(200, _clientActivityOvertime),
    queryParameters: {
      'getClientNames': '',
      'overTimeDataClients': '',
      'auth': 'token'
    },
  );
  dio.onGet(
    _apiPath,
    (request) => request.reply(200, _status),
    queryParameters: {'status': ''},
  );
  dio.onGet(
    _apiPath,
    (request) => request.reply(200, _status),
    queryParameters: {'enable': '', 'auth': 'token'},
  );
  dio.onGet(
    _apiPath,
    (request) => request.reply(200, _status),
    queryParameters: {'disable': '', 'auth': 'token'},
  );
  dio.onGet(
    _apiPath,
    (request) => request.reply(200, _status),
    queryParameters: {'disable': '30', 'auth': 'token'},
  );
  dio.onGet(
    _apiPath,
    (request) => request.reply(200, _queryItems),
    queryParameters: {'getAllQueries': '3', 'auth': 'token'},
  );
  dio.onGet(
    _apiPath,
    (request) => request.reply(200, _topItems),
    queryParameters: {'topItems': '', 'auth': 'token'},
  );
  dio.onGet(
    _apiPath,
    (request) => request.reply(200, _versions),
    queryParameters: {'versions': ''},
  );
  dio.onGet(
    _apiPath,
    (request) => request.reply(200, _versions),
    queryParameters: {'versions': ''},
  );
  dio.onGet(
    _adminPath,
    (request) => request.reply(200, adminHtmlString),
  );
  return dio;
}
