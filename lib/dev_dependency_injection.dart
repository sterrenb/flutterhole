import 'package:alice/alice.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/numbers_api/data/repositories/numbers_api_repository.dart';
import 'package:flutterhole/features/pihole_api/data/datasources/api_data_source.dart';
import 'package:flutterhole/features/pihole_api/data/models/dns_query_type.dart';
import 'package:flutterhole/features/pihole_api/data/models/forward_destinations.dart';
import 'package:flutterhole/features/pihole_api/data/models/many_query_data.dart';
import 'package:flutterhole/features/pihole_api/data/models/over_time_data.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_client.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_status.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_versions.dart';
import 'package:flutterhole/features/pihole_api/data/models/query_data.dart';
import 'package:flutterhole/features/pihole_api/data/models/summary.dart';
import 'package:flutterhole/features/pihole_api/data/models/toggle_status.dart';
import 'package:flutterhole/features/pihole_api/data/models/top_items.dart';
import 'package:flutterhole/features/pihole_api/data/models/top_sources.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/features/settings/services/preference_service.dart';
import 'package:flutterhole/features/settings/services/preference_service_impl.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:preferences/preferences.dart';
import 'package:sailor/sailor.dart';

@registerModule
abstract class RegisterDevModule {
  @dev
  @injectable
  Dio get dio => Dio(BaseOptions(baseUrl: 'http://dev.com'));

  @dev
  @preResolve
  @singleton
  Future<HiveInterface> get hive async {
    await Hive.deleteFromDisk();
    await Hive.initFlutter('dev');
    return Hive;
  }

  @dev
  @singleton
  Sailor get sailor => Sailor(
          options: SailorOptions(
        isLoggingEnabled: true,
      ));

  @dev
  @singleton
  Alice get alice => Alice(
        showNotification: false,
        darkTheme: true,
      );
}

@dev
@injectable
@RegisterAs(ApiDataSource)
class ApiDataSourceDev implements ApiDataSource {
  @override
  Future<ToggleStatus> disablePihole(PiholeSettings settings) async {
    return ToggleStatus(PiStatusEnum.disabled);
  }

  @override
  Future<ToggleStatus> enablePihole(PiholeSettings settings) async {
    return ToggleStatus(PiStatusEnum.enabled);
  }

  @override
  Future<ForwardDestinationsResult> fetchForwardDestinations(
      PiholeSettings settings) async {
    return ForwardDestinationsResult(forwardDestinations: {
      ForwardDestination(title: 'blocklist'): 25.5,
      ForwardDestination(title: 'cache'): 14.5,
      ForwardDestination(title: 'example.com', ip: '1.2.3.4'): 35,
      ForwardDestination(ip: '5.6.7.8'): 5,
    });
  }

  @override
  Future<ManyQueryData> fetchManyQueryData(PiholeSettings settings,
      [int maxResults]) async {
    return ManyQueryData(data: [
      QueryData(
        timestamp: DateTime.fromMillisecondsSinceEpoch(1590058147934),
        queryType: QueryType.A,
        domain: 'query.org',
        clientName: 'my-client',
        queryStatus: QueryStatus.Forwarded,
        dnsSecStatus: DnsSecStatus.Insecure,
        replyDuration: Duration(milliseconds: 123),
      ),
      QueryData(
        timestamp: DateTime.fromMillisecondsSinceEpoch(15958147934),
        queryType: QueryType.PTR,
        domain: 'pointer.org',
        clientName: 'pointer-client',
        queryStatus: QueryStatus.Cached,
        dnsSecStatus: DnsSecStatus.Bogus,
        replyDuration: Duration(milliseconds: 321),
      ),
    ]);
  }

  @override
  Future<OverTimeData> fetchQueriesOverTime(PiholeSettings settings) async {
    return _overTimeDataFromJson();
  }

  @override
  Future<ManyQueryData> fetchQueryDataForClient(
      PiholeSettings settings, PiClient client) async {
    return ManyQueryData(data: [
      QueryData(
        timestamp: DateTime.fromMillisecondsSinceEpoch(1590058147934),
        queryType: QueryType.A,
        domain: 'query.org',
        clientName: '${client.titleOrIp}',
        queryStatus: QueryStatus.Forwarded,
        dnsSecStatus: DnsSecStatus.Insecure,
        replyDuration: Duration(milliseconds: 123),
      ),
      QueryData(
        timestamp: DateTime.fromMillisecondsSinceEpoch(15958147934),
        queryType: QueryType.PTR,
        domain: 'pointer.org',
        clientName: '${client.titleOrIp}',
        queryStatus: QueryStatus.Cached,
        dnsSecStatus: DnsSecStatus.Bogus,
        replyDuration: Duration(milliseconds: 321),
      ),
    ]);
  }

  @override
  Future<ManyQueryData> fetchQueryDataForDomain(
      PiholeSettings settings, String domain) async {
    return ManyQueryData(data: [
      QueryData(
        timestamp: DateTime.fromMillisecondsSinceEpoch(1590058147934),
        queryType: QueryType.A,
        domain: '$domain',
        clientName: 'my-client',
        queryStatus: QueryStatus.Forwarded,
        dnsSecStatus: DnsSecStatus.Insecure,
        replyDuration: Duration(milliseconds: 123),
      ),
      QueryData(
        timestamp: DateTime.fromMillisecondsSinceEpoch(15958147934),
        queryType: QueryType.PTR,
        domain: '$domain',
        clientName: 'pointer-client',
        queryStatus: QueryStatus.Cached,
        dnsSecStatus: DnsSecStatus.Bogus,
        replyDuration: Duration(milliseconds: 321),
      ),
    ]);
  }

  @override
  Future<DnsQueryTypeResult> fetchQueryTypes(PiholeSettings settings) async {
    return DnsQueryTypeResult(
      dnsQueryTypes: [
        DnsQueryType(title: 'A (IPv4)', fraction: 60.40),
        DnsQueryType(title: 'AAAA (IPv6)', fraction: 5),
        DnsQueryType(title: 'ANY', fraction: 18.09),
        DnsQueryType(title: 'SRV', fraction: 11.91),
        DnsQueryType(title: 'SOA', fraction: 2),
        DnsQueryType(title: 'PTR', fraction: 2.60),
        DnsQueryType(title: 'TXT', fraction: 0),
      ],
    );
  }

  @override
  Future<SummaryModel> fetchSummary(PiholeSettings settings) async {
    return SummaryModel(
      domainsBeingBlocked: 128977,
      dnsQueriesToday: 80085,
      adsBlockedToday: 44875,
      adsPercentageToday: 56.03,
      uniqueDomains: 10897,
      queriesForwarded: 13653,
      queriesCached: 1072,
      clientsEverSeen: 13,
      uniqueClients: 11,
      dnsQueriesAllTypes: 14773,
      replyNoData: 59,
      replyNxDomain: 528,
      replyCName: 7603,
      replyIP: 4818,
      privacyLevel: 0,
      status: PiStatusEnum.enabled,
    );
  }

  @override
  Future<TopItems> fetchTopItems(PiholeSettings settings) async {
    return TopItems(
      topQueries: {
        "0.debian.pool.ntp.org": 744,
        "1.debian.pool.ntp.org": 744,
        "2.debian.pool.ntp.org": 744,
        "3.debian.pool.ntp.org": 744,
        "time.apple.com": 100,
        "indigo.tvaddons.co": 100,
        "www.google.com": 54,
        "8.8.8.8.in-addr.arpa": 50,
        "4.4.8.8.in-addr.arpa": 50,
        "ssl.gstatic.com": 27,
      },
      topAds: {
        "activity.windows.com": 28,
        "graph.facebook.com": 9,
        "googleads.g.doubleclick.net": 8,
        "www.google-analytics.com": 7,
        "www.googletagmanager.com": 7,
        "www.googletagservices.com": 6,
      },
    );
  }

  @override
  Future<TopSourcesResult> fetchTopSources(PiholeSettings settings) async {
    return TopSourcesResult(
      topSources: {
        PiClient(title: 'localhost', ip: '127.0.0.1'): 3204,
        PiClient(title: 'openelec', ip: '10.0.1.2'): 324,
        PiClient(ip: '10.0.1.3'): 216,
        PiClient(title: 'laptop', ip: '10.0.1.4'): 96,
      },
    );
  }

  @override
  Future<PiVersions> fetchVersions(PiholeSettings settings) async {
    return PiVersions(
      hasCoreUpdate: false,
      currentCoreVersion: 'v5.0',
      latestCoreVersion: 'v5.0',
      coreBranch: 'master',
      hasWebUpdate: false,
      currentWebVersion: 'v5.0',
      latestWebVersion: 'v5.0',
      webBranch: 'beta',
      hasFtlUpdate: true,
      currentFtlVersion: 'v5.0',
      latestFtlVersion: 'v5.3',
      ftlBranch: 'master',
    );
  }

  @override
  Future<ToggleStatus> pingPihole(PiholeSettings settings) async {
    return ToggleStatus(PiStatusEnum.enabled);
  }

  @override
  Future<ToggleStatus> sleepPihole(
      PiholeSettings settings, Duration duration) async {
    return ToggleStatus(PiStatusEnum.disabled);
  }
}

@dev
@preResolve
@singleton
@RegisterAs(PreferenceService)
class PreferenceServiceDev extends PreferenceServiceImpl {
  @factoryMethod
  static Future<PreferenceServiceImpl> create() async {
    await PrefService.init(prefix: 'dev_');
    return PreferenceServiceDev();
  }
}

@dev
@singleton
@RegisterAs(NumbersApiRepository)
class NumbersApiRepositoryDev implements NumbersApiRepository {
  @override
  Future<Either<Failure, Map<int, String>>> fetchManyTrivia(
      List<int> integers) async {
    return Right(integers.asMap().map<int, String>((_, integer) => MapEntry(
        integer,
        '80,085 is an odd composite number composed of four prime numbers multiplied together.')));
  }

  @override
  Future<Either<Failure, String>> fetchTrivia(int integer) async {
    return Right('Some singular info for $integer');
  }
}

OverTimeData _overTimeDataFromJson() {
  final Map<String, dynamic> json = {
    "domains_over_time": {
      "1588197900": 58,
      "1588198500": 86,
      "1588199100": 59,
      "1588199700": 17,
      "1588200300": 12,
      "1588200900": 8,
      "1588201500": 2,
      "1588202100": 2,
      "1588202700": 0,
      "1588203300": 5,
      "1588203900": 0,
      "1588204500": 26,
      "1588205100": 14,
      "1588205700": 0,
      "1588206300": 0,
      "1588206900": 39,
      "1588207500": 0,
      "1588208100": 0,
      "1588208700": 18,
      "1588209300": 0,
      "1588209900": 1,
      "1588210500": 4,
      "1588211100": 0,
      "1588211700": 0,
      "1588212300": 14,
      "1588212900": 0,
      "1588213500": 0,
      "1588214100": 4,
      "1588214700": 0,
      "1588215300": 2,
      "1588215900": 14,
      "1588216500": 0,
      "1588217100": 0,
      "1588217700": 10,
      "1588218300": 3,
      "1588218900": 8,
      "1588219500": 39,
      "1588220100": 5,
      "1588220700": 1,
      "1588221300": 25,
      "1588221900": 0,
      "1588222500": 4,
      "1588223100": 20,
      "1588223700": 1,
      "1588224300": 2,
      "1588224900": 44,
      "1588225500": 12,
      "1588226100": 11,
      "1588226700": 57,
      "1588227300": 402,
      "1588227900": 250,
      "1588228500": 40,
      "1588229100": 745,
      "1588229700": 1151,
      "1588230300": 210,
      "1588230900": 229,
      "1588231500": 243,
      "1588232100": 232,
      "1588232700": 80,
      "1588233300": 193,
      "1588233900": 257,
      "1588234500": 164,
      "1588235100": 608,
      "1588235700": 121,
      "1588236300": 196,
      "1588236900": 149,
      "1588237500": 373,
      "1588238100": 173,
      "1588238700": 130,
      "1588239300": 157,
      "1588239900": 173,
      "1588240500": 400,
      "1588241100": 103,
      "1588241700": 406,
      "1588242300": 148,
      "1588242900": 130,
      "1588243500": 104,
      "1588244100": 111,
      "1588244700": 162,
      "1588245300": 270,
      "1588245900": 216,
      "1588246500": 154,
      "1588247100": 101,
      "1588247700": 158,
      "1588248300": 101,
      "1588248900": 176,
      "1588249500": 115,
      "1588250100": 74,
      "1588250700": 189,
      "1588251300": 304,
      "1588251900": 63,
      "1588252500": 84,
      "1588253100": 111,
      "1588253700": 117,
      "1588254300": 80,
      "1588254900": 183,
      "1588255500": 139,
      "1588256100": 92,
      "1588256700": 133,
      "1588257300": 199,
      "1588257900": 139,
      "1588258500": 161,
      "1588259100": 104,
      "1588259700": 343,
      "1588260300": 218,
      "1588260900": 238,
      "1588261500": 149,
      "1588262100": 161,
      "1588262700": 133,
      "1588263300": 122,
      "1588263900": 63,
      "1588264500": 36,
      "1588265100": 23,
      "1588265700": 2,
      "1588266300": 14,
      "1588266900": 0,
      "1588267500": 0,
      "1588268100": 27,
      "1588268700": 167,
      "1588269300": 17,
      "1588269900": 60,
      "1588270500": 39,
      "1588271100": 9,
      "1588271700": 32,
      "1588272300": 25,
      "1588272900": 32,
      "1588273500": 33,
      "1588274100": 44,
      "1588274700": 146,
      "1588275300": 74,
      "1588275900": 18,
      "1588276500": 57,
      "1588277100": 457,
      "1588277700": 174,
      "1588278300": 139,
      "1588278900": 124,
      "1588279500": 142,
      "1588280100": 193,
      "1588280700": 99,
      "1588281300": 55,
      "1588281900": 80
    },
    "ads_over_time": {
      "1588197900": 0,
      "1588198500": 0,
      "1588199100": 0,
      "1588199700": 0,
      "1588200300": 0,
      "1588200900": 0,
      "1588201500": 0,
      "1588202100": 0,
      "1588202700": 0,
      "1588203300": 0,
      "1588203900": 0,
      "1588204500": 0,
      "1588205100": 0,
      "1588205700": 0,
      "1588206300": 0,
      "1588206900": 0,
      "1588207500": 0,
      "1588208100": 0,
      "1588208700": 0,
      "1588209300": 0,
      "1588209900": 0,
      "1588210500": 0,
      "1588211100": 0,
      "1588211700": 0,
      "1588212300": 0,
      "1588212900": 0,
      "1588213500": 0,
      "1588214100": 0,
      "1588214700": 0,
      "1588215300": 0,
      "1588215900": 0,
      "1588216500": 0,
      "1588217100": 0,
      "1588217700": 0,
      "1588218300": 0,
      "1588218900": 0,
      "1588219500": 0,
      "1588220100": 0,
      "1588220700": 0,
      "1588221300": 0,
      "1588221900": 0,
      "1588222500": 0,
      "1588223100": 0,
      "1588223700": 0,
      "1588224300": 0,
      "1588224900": 0,
      "1588225500": 0,
      "1588226100": 0,
      "1588226700": 0,
      "1588227300": 0,
      "1588227900": 0,
      "1588228500": 0,
      "1588229100": 0,
      "1588229700": 0,
      "1588230300": 0,
      "1588230900": 0,
      "1588231500": 0,
      "1588232100": 0,
      "1588232700": 0,
      "1588233300": 0,
      "1588233900": 0,
      "1588234500": 0,
      "1588235100": 0,
      "1588235700": 0,
      "1588236300": 0,
      "1588236900": 0,
      "1588237500": 0,
      "1588238100": 0,
      "1588238700": 0,
      "1588239300": 0,
      "1588239900": 0,
      "1588240500": 0,
      "1588241100": 0,
      "1588241700": 0,
      "1588242300": 0,
      "1588242900": 0,
      "1588243500": 0,
      "1588244100": 0,
      "1588244700": 0,
      "1588245300": 0,
      "1588245900": 0,
      "1588246500": 0,
      "1588247100": 0,
      "1588247700": 0,
      "1588248300": 0,
      "1588248900": 0,
      "1588249500": 0,
      "1588250100": 1,
      "1588250700": 0,
      "1588251300": 0,
      "1588251900": 0,
      "1588252500": 0,
      "1588253100": 0,
      "1588253700": 0,
      "1588254300": 0,
      "1588254900": 0,
      "1588255500": 0,
      "1588256100": 0,
      "1588256700": 0,
      "1588257300": 0,
      "1588257900": 0,
      "1588258500": 0,
      "1588259100": 0,
      "1588259700": 0,
      "1588260300": 0,
      "1588260900": 0,
      "1588261500": 0,
      "1588262100": 0,
      "1588262700": 0,
      "1588263300": 0,
      "1588263900": 0,
      "1588264500": 0,
      "1588265100": 0,
      "1588265700": 0,
      "1588266300": 0,
      "1588266900": 0,
      "1588267500": 0,
      "1588268100": 0,
      "1588268700": 0,
      "1588269300": 0,
      "1588269900": 0,
      "1588270500": 0,
      "1588271100": 0,
      "1588271700": 0,
      "1588272300": 0,
      "1588272900": 0,
      "1588273500": 0,
      "1588274100": 0,
      "1588274700": 0,
      "1588275300": 0,
      "1588275900": 0,
      "1588276500": 0,
      "1588277100": 0,
      "1588277700": 0,
      "1588278300": 0,
      "1588278900": 0,
      "1588279500": 0,
      "1588280100": 0,
      "1588280700": 0,
      "1588281300": 0,
      "1588281900": 0
    }
  };

  return OverTimeData.fromJson(json);
}
