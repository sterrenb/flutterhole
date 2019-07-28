import 'package:flutterhole/model/api/summary.dart';
import "package:test/test.dart";

import '../mock.dart';

void main() {
  Summary summary;
  setUp(() {});

  test('constructor', () {
    summary = Summary();

    expect(summary.domainsBeingBlocked, isNull);
    expect(summary.dnsQueriesToday, isNull);
    expect(summary.adsBlockedToday, isNull);
    expect(summary.adsPercentageToday, isNull);
    expect(summary.uniqueDomains, isNull);
    expect(summary.queriesForwarded, isNull);
    expect(summary.queriesCached, isNull);
    expect(summary.clientsEverSeen, isNull);
    expect(summary.uniqueClients, isNull);
    expect(summary.dnsQueriesAllTypes, isNull);
    expect(summary.replyNodata, isNull);
    expect(summary.replyNxdomain, isNull);
    expect(summary.replyCname, isNull);
    expect(summary.replyIp, isNull);
    expect(summary.privacyLevel, isNull);
    expect(summary.status, isNull);
    expect(summary.gravityLastUpdated, isNull);
  });

  test('fromString', () {
    expect(
        Summary.fromString(
            '{"domains_being_blocked":0,"dns_queries_today":1,"ads_blocked_today":2,"ads_percentage_today":2.345,"unique_domains":3,"queries_forwarded":4,"queries_cached":5,"clients_ever_seen":6,"unique_clients":7,"dns_queries_all_types":8,"reply_NODATA":9,"reply_NXDOMAIN":10,"reply_CNAME":11,"reply_IP":12,"privacy_level":13,"status":"enabled","gravity_last_updated":{"file_exists":true,"absolute":14,"relative":{"days":"15","hours":"16","minutes":"17"}}}'),
        mockSummary);
  });

  test('toJson', () {
    expect(mockSummary.toJson(), {
      "domains_being_blocked": mockSummary.domainsBeingBlocked,
      "dns_queries_today": mockSummary.dnsQueriesToday,
      "ads_blocked_today": mockSummary.adsBlockedToday,
      "ads_percentage_today": mockSummary.adsPercentageToday,
      "unique_domains": mockSummary.uniqueDomains,
      "queries_forwarded": mockSummary.queriesForwarded,
      "queries_cached": mockSummary.queriesCached,
      "clients_ever_seen": mockSummary.clientsEverSeen,
      "unique_clients": mockSummary.uniqueClients,
      "dns_queries_all_types": mockSummary.dnsQueriesAllTypes,
      "reply_NODATA": mockSummary.replyNodata,
      "reply_NXDOMAIN": mockSummary.replyNxdomain,
      "reply_CNAME": mockSummary.replyCname,
      "reply_IP": mockSummary.replyIp,
      "privacy_level": mockSummary.privacyLevel,
      "status": mockSummary.status,
      "gravity_last_updated": mockSummary.gravityLastUpdated.toJson()
    });
  });

  test('fromJson', () {
    expect(
        Summary.fromJson({
          "domains_being_blocked": mockSummary.domainsBeingBlocked,
          "dns_queries_today": mockSummary.dnsQueriesToday,
          "ads_blocked_today": mockSummary.adsBlockedToday,
          "ads_percentage_today": mockSummary.adsPercentageToday,
          "unique_domains": mockSummary.uniqueDomains,
          "queries_forwarded": mockSummary.queriesForwarded,
          "queries_cached": mockSummary.queriesCached,
          "clients_ever_seen": mockSummary.clientsEverSeen,
          "unique_clients": mockSummary.uniqueClients,
          "dns_queries_all_types": mockSummary.dnsQueriesAllTypes,
          "reply_NODATA": mockSummary.replyNodata,
          "reply_NXDOMAIN": mockSummary.replyNxdomain,
          "reply_CNAME": mockSummary.replyCname,
          "reply_IP": mockSummary.replyIp,
          "privacy_level": mockSummary.privacyLevel,
          "status": mockSummary.status,
          "gravity_last_updated": mockSummary.gravityLastUpdated.toJson()
        }),
        mockSummary);
  });
}
