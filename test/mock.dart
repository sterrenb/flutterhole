import 'package:flutterhole/model/blacklist.dart';
import 'package:flutterhole/model/status.dart';
import 'package:flutterhole/model/summary.dart';
import 'package:flutterhole/model/top_sources.dart';
import 'package:flutterhole/model/whitelist.dart';

final mockStatusEnabled = Status(enabled: true);
final mockStatusDisabled = Status(enabled: false);

final mockWhitelist = Whitelist(list: ['a.com', 'b.org', 'c.net']);
final mockBlacklist = Blacklist(exact: [
  BlacklistItem.exact(entry: 'exact.com'),
  BlacklistItem.exact(entry: 'pi-hole.net'),
], wildcard: [
  BlacklistItem.wildcard(entry: 'wildcard.com'),
  BlacklistItem.regex(entry: 'regex')
]);

final mockSummary = Summary(
    domainsBeingBlocked: 0,
    dnsQueriesToday: 1,
    adsBlockedToday: 2,
    adsPercentageToday: 2.345,
    uniqueDomains: 3,
    queriesForwarded: 4,
    queriesCached: 5,
    clientsEverSeen: 6,
    uniqueClients: 7,
    dnsQueriesAllTypes: 8,
    replyNodata: 9,
    replyNxdomain: 10,
    replyCname: 11,
    replyIp: 12,
    privacyLevel: 13,
    status: 'enabled',
    gravityLastUpdated: GravityLastUpdated(
        fileExists: true,
        absolute: 14,
        relative: Relative(days: '15', hours: '16', minutes: '17')));

final TopSources mockTopSources = TopSources({
  '10.0.1.1': 55,
  '10.0.1.2': 42,
  'windows|10.0.1.3': 33,
  'osx|10.0.1.4': 24,
  'zenwatch3|10.0.1.5': 11,
});
