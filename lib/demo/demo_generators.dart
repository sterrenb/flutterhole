import 'dart:math';

import 'package:faker/faker.dart';
import 'package:flutterhole/constants/urls.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:pihole_api/pihole_api.dart';

final _faker = Faker();
final _random = Random();

Duration randomDayDuration() => Duration(
    hours: _random.nextInt(24),
    minutes: _random.nextInt(60),
    seconds: _random.nextInt(60));

QueryItem randomQueryItem([Duration duration = Duration.zero]) {
  return QueryItem(
      timestamp: DateTime.now().subtract(duration),
      queryType: 'A',
      domain: _random.nextDouble() > .96
          ? KUrls.developerHomeUrl
          : _faker.internet.domainName(),
      clientName: _faker.internet.ipv4Address(),
      queryStatus: _random.nextDouble() > .66
          ? QueryStatus.Forwarded
          : QueryStatus.values[_random.nextInt(7) + 1],
      // .elementAt(random.nextInt(QueryStatus.values.length)),
      dnsSecStatus:
          DnsSecStatus.values[_random.nextInt(DnsSecStatus.values.length)],
      delta: 0.0);
}

Map<DateTime, int> randomDomainsOverTime({
  int length = 30,
  int min = 0,
  int max = 100,
  int? seed,
}) {
  final random = seed == null ? _random : Random(seed);
  final interval = 10;
  final now = DateTime.now();
  final end = DateTime(now.year, now.month, now.day, now.hour,
      now.minute - (now.minute % interval));

  final deviation = 10;
  int value = ((max - min) ~/ 2) + min;
  return Map.fromIterables(
    List.generate(length, (index) {
      return end.subtract(Duration(minutes: index * interval));
    }).reversed,
    List.generate(length, (index) {
      value = value +
          random.nextInt(deviation ~/ 2) -
          random.nextInt(deviation ~/ 2);
      return value;
    }),
  );
}
