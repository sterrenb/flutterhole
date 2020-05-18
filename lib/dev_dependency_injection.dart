import 'package:alice/alice.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutterhole/core/models/exceptions.dart';
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
    // TODO: implement fetchQueriesOverTime
    throw PiException.emptyResponse('fake dev error');

    return OverTimeData(
      domainsOverTime: {},
      adsOverTime: {},
    );
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
      dnsQueriesToday: 14773,
      adsBlockedToday: 4875,
      adsPercentageToday: 33.21,
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
    return Right(integers.asMap().map<int, String>(
        (_, integer) => MapEntry(integer, 'Some cool info for $integer.')));
  }

  @override
  Future<Either<Failure, String>> fetchTrivia(int integer) async {
    return Right('Some singular info for $integer');
  }
}
