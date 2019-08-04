import 'package:flutterhole/model/api/query.dart';
import 'package:intl/intl.dart';

final timestampFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');

/// Returns a String representation with a coma every 3 digits
String numWithCommas(num i) {
  final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  final Function matchFunc = (Match match) => '${match[1]},';
  return i.toString().replaceAllMapped(reg, matchFunc);
}

DateTime epochToDateTime(String source) =>
    DateTime.fromMillisecondsSinceEpoch(int.parse(source + '000'));

String dnsSecStatusToString(DnsSecStatus dnsSecStatus) {
  return dnsSecStatus == DnsSecStatus.Empty
      ? 'no DNSSEC'
      : dnsSecStatus.toString().replaceAll('DnsSecStatus.', '');
}

QueryType stringToQueryType(String str) {
  for (QueryType type in QueryType.values) {
    if (type.toString().contains(str
        .split(' ')
        .first)) return type;
  }

  return QueryType.values.last;
}

String queryTypeToString(QueryType type) {
  return type == QueryType.UNKN
      ? 'Unknown'
      : type.toString().replaceAll('QueryType.', '');
}

String queryStatusToJson(QueryStatus status) {
  return (QueryStatus.values.indexOf(status) + 1).toString();
}

String dnsSecStatusToJson(DnsSecStatus status) {
  return (DnsSecStatus.values.indexOf(status) + 1).toString();
}

String queryStatusToString(QueryStatus status) {
  switch (status) {
    case QueryStatus.BlockedWithGravity:
      return 'Blocked (gravity)';
    case QueryStatus.Forwarded:
      return 'OK (forwarded)';
    case QueryStatus.Cached:
      return 'OK (cached)';
    case QueryStatus.BlockedWithRegexWildcard:
      return 'Blocked (regex/wildcard)';
    case QueryStatus.BlockedWithBlacklist:
      return 'Blocked (blacklist)';
    case QueryStatus.BlockedWithExternalIP:
      return 'Blocked (external, IP)';
      break;
    case QueryStatus.BlockedWithExternalNull:
      return 'Blocked (external, NULL)';
      break;
    case QueryStatus.BlockedWithExternalNXRA:
      return 'Blocked (external, NXRA)';
      break;
    case QueryStatus.Unknown:
      return 'Unknown';
      break;
    default:
      return 'Empty';
  }
}

String durationToTimeString(Duration duration) {
  return duration.inHours.toString() +
      ':' +
      (duration.inMinutes % Duration.minutesPerHour)
          .toString()
          .padLeft(2, '0') +
      ':' +
      (duration.inSeconds % Duration.secondsPerMinute)
          .toString()
          .padLeft(2, '0');
}
