import 'package:flutterhole/model/api/query.dart';
import 'package:flutterhole/service/convert.dart';
import "package:test/test.dart";

void main() {
  test('numWithCommas', () {
    expect(numWithCommas(123), '123');
    expect(numWithCommas(1234), '1,234');
    expect(numWithCommas(12345), '12,345');
    expect(numWithCommas(123456), '123,456');
    expect(numWithCommas(1234567), '1,234,567');
  });

  test('epochToDateTime', () {
    expect(epochToDateTime('1563995'),
        DateTime.fromMillisecondsSinceEpoch(1563995000));
  });

  test('dnsSecStatusToString', () {
    expect(dnsSecStatusToString(DnsSecStatus.Secure), 'Secure');
    expect(dnsSecStatusToString(DnsSecStatus.Insecure), 'Insecure');
    expect(dnsSecStatusToString(DnsSecStatus.Bogus), 'Bogus');
    expect(dnsSecStatusToString(DnsSecStatus.Abandoned), 'Abandoned');
    expect(dnsSecStatusToString(DnsSecStatus.Unknown), 'Unknown');
    expect(dnsSecStatusToString(DnsSecStatus.Empty), 'no DNSSEC');
  });

  test('stringToQueryType', () {
    expect(stringToQueryType('A'), QueryType.A);
    expect(stringToQueryType('AAAA'), QueryType.AAAA);
    expect(stringToQueryType('SRV'), QueryType.SRV);
    expect(stringToQueryType('SOA'), QueryType.SOA);
    expect(stringToQueryType('PTR'), QueryType.PTR);
    expect(stringToQueryType('TXT'), QueryType.TXT);
    expect(stringToQueryType('invalid'), QueryType.UNKN);
  });

  test('queryTypeToJson', () {
    expect(queryStatusToJson(QueryStatus.BlockedWithGravity), '1');
    expect(queryStatusToJson(QueryStatus.Forwarded), '2');
    expect(queryStatusToJson(QueryStatus.Cached), '3');
    expect(queryStatusToJson(QueryStatus.BlockedWithRegexWildcard), '4');
    expect(queryStatusToJson(QueryStatus.BlockedWithBlacklist), '5');
    expect(queryStatusToJson(QueryStatus.BlockedWithExternalIP), '6');
    expect(queryStatusToJson(QueryStatus.BlockedWithExternalNull), '7');
    expect(queryStatusToJson(QueryStatus.BlockedWithExternalNXRA), '8');
    expect(queryStatusToJson(QueryStatus.Unknown), '9');
  });

  test('queryStatusToString', () {
    expect(queryStatusToString(QueryStatus.BlockedWithGravity),
        'Blocked (gravity)');
    expect(queryStatusToString(QueryStatus.Forwarded), 'OK (forwarded)');
    expect(queryStatusToString(QueryStatus.Cached), 'OK (cached)');
    expect(queryStatusToString(QueryStatus.BlockedWithRegexWildcard),
        'Blocked (regex/wildcard)');
    expect(queryStatusToString(QueryStatus.BlockedWithBlacklist),
        'Blocked (blacklist)');
    expect(queryStatusToString(QueryStatus.BlockedWithExternalIP),
        'Blocked (external, IP)');
    expect(queryStatusToString(QueryStatus.BlockedWithExternalNull),
        'Blocked (external, NULL)');
    expect(queryStatusToString(QueryStatus.BlockedWithExternalNXRA),
        'Blocked (external, NXRA)');
    expect(queryStatusToString(QueryStatus.Unknown), 'Unknown');
    expect(queryStatusToString(null), 'Empty');
  });

  test('dnsSecStatusToJson', () {
    expect(dnsSecStatusToJson(DnsSecStatus.Secure), '1');
    expect(dnsSecStatusToJson(DnsSecStatus.Insecure), '2');
    expect(dnsSecStatusToJson(DnsSecStatus.Bogus), '3');
    expect(dnsSecStatusToJson(DnsSecStatus.Abandoned), '4');
    expect(dnsSecStatusToJson(DnsSecStatus.Unknown), '5');
    expect(dnsSecStatusToJson(DnsSecStatus.Empty), '6');
  });
}
