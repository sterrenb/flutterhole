import 'package:flutterhole/model/api/query.dart';
import "package:test/test.dart";

import '../mock.dart';

void main() {
  group('Query', () {
    Query query;
    List<dynamic> list;

    setUp(() {
      list = ['1563995000', 'A', 'test.com', 'localhost', '3', '1'];
    });

    test('constructor', () {
      query = Query();

      expect(query.time, isNull);
      expect(query.queryType, isNull);
      expect(query.entry, isNull);
      expect(query.client, isNull);
      expect(query.queryStatus, isNull);
      expect(query.dnsSecStatus, isNull);
    });

    group('fromJson', () {
      test('valid', () {
        expect(Query.fromJson(list), mockQueries.first);
      });

      test('unknown query status', () {
        list = ['1563995000', 'A', 'test.com', 'localhost', '99', '1'];
        expect(Query.fromJson(list).queryStatus, QueryStatus.Unknown);
      });

      test('empty dnssec status', () {
        list = ['1563995000', 'A', 'test.com', 'localhost', '3', '99'];
        expect(Query.fromJson(list).dnsSecStatus, DnsSecStatus.Empty);
      });
    });

    test('toJson', () {
      expect(mockQueries.first.toJson(), list);
    });
  });

  group('QueryTypes', () {
    Map<String, dynamic> map;
    String str;

    setUp(() {
      map = {
        'querytypes': {
          "A (IPv4)": 58.46,
          "AAAA (IPv6)": 10.12,
          "ANY": 10.50,
          "SRV": 0.45,
          "SOA": 9.50,
          "PTR": 2.97,
          "TXT": 8.0,
        }
      };
      str =
          '{\"querytypes\":{\"A (IPv4)\":58.46,\"AAAA (IPv6)\":10.12,\"ANY\":10.5,\"SRV\":0.45,\"SOA\":9.5,\"PTR\":2.97,\"TXT\":8.0}}';
    });

    test('fromString', () {
      expect(QueryTypes.fromString(str), mockQueryTypes);
    });

    test('fromJson', () {
      expect(QueryTypes.fromJson(map), mockQueryTypes);
    });

    test('toJson', () {
      expect(mockQueryTypes.toJson(), map);
    });
  });
}
