import 'package:flutterhole/model/api/forward_destinations.dart';
import "package:test/test.dart";

import '../mock.dart';

void main() {
  ForwardDestinations forwardDestinations;
  Map<String, dynamic> map;
  String str;
  setUp(() {
    map = {
      "forward_destinations": {
        "blocklist|blocklist": 9.7,
        "cache|cache": 14.37,
        "dns.google|8.8.4.4": 40.41,
        "dns.google|8.8.8.8": 35.53
      }
    };
    str =
        '{\"forward_destinations\":{\"blocklist|blocklist\":9.7,\"cache|cache\":14.37,\"dns.google|8.8.4.4\":40.41,\"dns.google|8.8.8.8\":35.53}}';
  });

  test('constructor', () {
    forwardDestinations = ForwardDestinations({});
    expect(forwardDestinations.values, isEmpty);
    expect(forwardDestinations.items, isEmpty);
  });

  test('items', () {
    expect(mockForwardDestinations.items, [
      ForwardDestinationItem(
          ipString: 'blocklist', title: 'blocklist', percent: 9.7),
      ForwardDestinationItem(ipString: 'cache', title: 'cache', percent: 14.37),
      ForwardDestinationItem(
          ipString: '8.8.4.4', title: 'dns.google', percent: 40.41),
      ForwardDestinationItem(
          ipString: '8.8.8.8', title: 'dns.google', percent: 35.53),
    ]);
  });

  test('fromString', () {
    expect(ForwardDestinations.fromString(str), mockForwardDestinations);
  });

  test('toJson', () {
    expect(mockForwardDestinations.toJson(), map);
  });

  test('fromJson', () {
    expect(ForwardDestinations.fromJson(map), mockForwardDestinations);
  });
}
