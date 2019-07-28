import 'package:flutterhole/model/api/query.dart';
import 'package:flutterhole/service/convert.dart';
import "package:test/test.dart";

void main() {
  test('epochToDateTime', () {
    expect(epochToDateTime('1563995'),
        DateTime.fromMillisecondsSinceEpoch(1563995000));
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

  test('dnsSecStatusToJson', () {
    expect(dnsSecStatusToJson(DnsSecStatus.Secure), '1');
    expect(dnsSecStatusToJson(DnsSecStatus.Insecure), '2');
    expect(dnsSecStatusToJson(DnsSecStatus.Bogus), '3');
    expect(dnsSecStatusToJson(DnsSecStatus.Abandoned), '4');
    expect(dnsSecStatusToJson(DnsSecStatus.Unknown), '5');
    expect(dnsSecStatusToJson(DnsSecStatus.Empty), '6');
  });
}
