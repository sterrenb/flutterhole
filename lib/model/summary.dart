import 'dart:convert';

import 'package:equatable/equatable.dart';

/// The Api model for http://pi.hole/admin/api.php?summary.
class Summary extends Equatable {
  int domainsBeingBlocked;
  int dnsQueriesToday;
  int adsBlockedToday;
  double adsPercentageToday;
  int uniqueDomains;
  int queriesForwarded;
  int queriesCached;
  int clientsEverSeen;
  int uniqueClients;
  int dnsQueriesAllTypes;
  int replyNodata;
  int replyNxdomain;
  int replyCname;
  int replyIp;
  int privacyLevel;
  String status;
  GravityLastUpdated gravityLastUpdated;

  Summary({
    this.domainsBeingBlocked,
    this.dnsQueriesToday,
    this.adsBlockedToday,
    this.adsPercentageToday,
    this.uniqueDomains,
    this.queriesForwarded,
    this.queriesCached,
    this.clientsEverSeen,
    this.uniqueClients,
    this.dnsQueriesAllTypes,
    this.replyNodata,
    this.replyNxdomain,
    this.replyCname,
    this.replyIp,
    this.privacyLevel,
    this.status,
    this.gravityLastUpdated,
  }) : super([
          domainsBeingBlocked,
          dnsQueriesToday,
          adsBlockedToday,
          adsPercentageToday,
          uniqueDomains,
          queriesForwarded,
          queriesCached,
          clientsEverSeen,
          uniqueClients,
          dnsQueriesAllTypes,
          replyNodata,
          replyNxdomain,
          replyCname,
          replyIp,
          privacyLevel,
          status,
          gravityLastUpdated,
        ]);

  factory Summary.fromJson(String str) => Summary.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Summary.fromMap(Map<String, dynamic> json) => new Summary(
        domainsBeingBlocked: json["domains_being_blocked"],
        dnsQueriesToday: json["dns_queries_today"],
        adsBlockedToday: json["ads_blocked_today"],
        adsPercentageToday: json["ads_percentage_today"].toDouble(),
        uniqueDomains: json["unique_domains"],
        queriesForwarded: json["queries_forwarded"],
        queriesCached: json["queries_cached"],
        clientsEverSeen: json["clients_ever_seen"],
        uniqueClients: json["unique_clients"],
        dnsQueriesAllTypes: json["dns_queries_all_types"],
        replyNodata: json["reply_NODATA"],
        replyNxdomain: json["reply_NXDOMAIN"],
        replyCname: json["reply_CNAME"],
        replyIp: json["reply_IP"],
        privacyLevel: json["privacy_level"],
        status: json["status"],
        gravityLastUpdated:
            GravityLastUpdated.fromMap(json["gravity_last_updated"]),
      );

  Map<String, dynamic> toMap() => {
        "domains_being_blocked": domainsBeingBlocked,
        "dns_queries_today": dnsQueriesToday,
        "ads_blocked_today": adsBlockedToday,
        "ads_percentage_today": adsPercentageToday,
        "unique_domains": uniqueDomains,
        "queries_forwarded": queriesForwarded,
        "queries_cached": queriesCached,
        "clients_ever_seen": clientsEverSeen,
        "unique_clients": uniqueClients,
        "dns_queries_all_types": dnsQueriesAllTypes,
        "reply_NODATA": replyNodata,
        "reply_NXDOMAIN": replyNxdomain,
        "reply_CNAME": replyCname,
        "reply_IP": replyIp,
        "privacy_level": privacyLevel,
        "status": status,
        "gravity_last_updated": gravityLastUpdated.toMap(),
      };
}

class GravityLastUpdated extends Equatable {
  bool fileExists;
  int absolute;
  Relative relative;

  GravityLastUpdated({
    this.fileExists,
    this.absolute,
    this.relative,
  }) : super([
          fileExists,
          absolute,
          relative,
        ]);

  factory GravityLastUpdated.fromJson(String str) =>
      GravityLastUpdated.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory GravityLastUpdated.fromMap(Map<String, dynamic> json) =>
      new GravityLastUpdated(
        fileExists: json["file_exists"],
        absolute: json["absolute"],
        relative: Relative.fromMap(json["relative"]),
      );

  Map<String, dynamic> toMap() => {
        "file_exists": fileExists,
        "absolute": absolute,
        "relative": relative.toMap(),
      };
}

class Relative extends Equatable {
  String days;
  String hours;
  String minutes;

  Relative({
    this.days,
    this.hours,
    this.minutes,
  }) : super([
          days,
          hours,
          minutes,
        ]);

  factory Relative.fromJson(String str) => Relative.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Relative.fromMap(Map<String, dynamic> json) => new Relative(
        days: json["days"],
        hours: json["hours"],
        minutes: json["minutes"],
      );

  Map<String, dynamic> toMap() => {
        "days": days,
        "hours": hours,
        "minutes": minutes,
      };
}
