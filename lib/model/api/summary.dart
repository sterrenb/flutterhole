import 'dart:convert';

import 'package:flutterhole/model/serializable.dart';

/// The API model for http://pi.hole/admin/api.php?summary.
class Summary extends Serializable {
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
  });

  final int domainsBeingBlocked;
  final int dnsQueriesToday;
  final int adsBlockedToday;
  final double adsPercentageToday;
  final int uniqueDomains;
  final int queriesForwarded;
  final int queriesCached;
  final int clientsEverSeen;
  final int uniqueClients;
  final int dnsQueriesAllTypes;
  final int replyNodata;
  final int replyNxdomain;
  final int replyCname;
  final int replyIp;
  final int privacyLevel;
  final String status;
  final GravityLastUpdated gravityLastUpdated;

  @override
  List<Object> get props =>
      [
        domainsBeingBlocked,
        dnsQueriesToday,
        adsBlockedToday,
        adsPercentageToday,
        uniqueDomains,
        queriesForwarded,
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
      ];

  factory Summary.fromString(String str) => Summary.fromJson(json.decode(str));

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
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
            GravityLastUpdated.fromJson(json["gravity_last_updated"]),
      );

  @override
  Map<String, dynamic> toJson() => {
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
    "gravity_last_updated": gravityLastUpdated.toJson(),
      };
}

class GravityLastUpdated extends Serializable {
  GravityLastUpdated({
    this.fileExists,
    this.absolute,
    this.relative,
  });

  final bool fileExists;
  final int absolute;
  final Relative relative;

  @override
  List<Object> get props => [fileExists, absolute, relative];

  factory GravityLastUpdated.fromJson(Map<String, dynamic> json) =>
      new GravityLastUpdated(
        fileExists: json["file_exists"],
        absolute: json["absolute"],
        relative: Relative.fromJson(json["relative"]),
      );

  @override
  Map<String, dynamic> toJson() =>
      {
        "file_exists": fileExists,
        "absolute": absolute,
        "relative": relative.toJson(),
      };
}

class Relative extends Serializable {
  Relative({
    this.days,
    this.hours,
    this.minutes,
  })
  ;

  final String days;
  final String hours;
  final String minutes;

  @override
  List<Object> get props => [days, hours, minutes];

  factory Relative.fromJson(Map<String, dynamic> json) => new Relative(
        days: json["days"],
        hours: json["hours"],
        minutes: json["minutes"],
      );

  @override
  Map<String, dynamic> toJson() =>
      {
        "days": days,
        "hours": hours,
        "minutes": minutes,
      };
}
