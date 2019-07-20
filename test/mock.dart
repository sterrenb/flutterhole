import 'package:flutterhole/model/blacklist.dart';
import 'package:flutterhole/model/status.dart';
import 'package:flutterhole/model/summary.dart';
import 'package:flutterhole/model/top_items.dart';
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

final TopItems mockTopItems = TopItems(
  {
    "clients1.google.com": 1005,
    "0.debian.pool.ntp.org": 728,
    "1.debian.pool.ntp.org": 728,
    "2.debian.pool.ntp.org": 728,
    "3.debian.pool.ntp.org": 728,
    "www.google.com": 222,
    "semanticlocation-pa.googleapis.com": 186,
    "connectivitycheck.gstatic.com": 179,
    "play.googleapis.com": 155,
    "time.apple.com": 101
  },
  {
    "indigo.tvaddons.co.uilenstede4.duwo.lan": 98,
    "lw10-10815.local.nl.bol.com": 32,
    "wpad.local.nl.bol.com": 27,
    "wpad.uilenstede4.duwo.lan": 24,
    "ads.google.com": 18,
    "_ldap._tcp.papendorp._sites.dc._msdcs.local.nl.bol.com": 13,
    "_ldap._tcp.default-first-site-name._sites.dc._msdcs.local.nl.bol.com": 13,
    "mobile.pipe.aria.microsoft.com": 11,
    "wpad.duwo.lan": 8,
    "update.openelec.tv.uilenstede4.duwo.lan": 8
  },
);
