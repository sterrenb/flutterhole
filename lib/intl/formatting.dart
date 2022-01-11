import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterhole/constants/colors.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pihole_api/pihole_api.dart';

const JsonEncoder _jsonEncoder = JsonEncoder.withIndent('  ');
final _numberFormat = NumberFormat();

class Formatting {
  static String logLevelToString(LogLevel l) => {
        LogLevel.debug: 'Debug',
        LogLevel.info: 'Info',
        LogLevel.warning: 'Warning',
        LogLevel.error: 'Error',
      }[l]!;

  static String temperatureReadingToString(TemperatureReading t) => {
        TemperatureReading.celcius: 'Celcius (°C)',
        TemperatureReading.fahrenheit: 'Fahrenheit (°F)',
        TemperatureReading.kelvin: 'Kelvin (°K)',
      }[t]!;

  static String secondsOrElse(int seconds, String orElse) =>
      Intl.plural(seconds,
          zero: orElse, one: '$seconds second', other: '$seconds seconds');

  static String jsonToCode(Map<String, dynamic> json) {
    return _jsonEncoder.convert(json);
  }

  static String errorToDescription(Object e) {
    if (e is PiholeApiFailure) {
      final message = e.when(
        notFound: () => "Not found.",
        notAuthenticated: () => "Not authenticated.",
        invalidResponse: (response) =>
            "The server responded with status code $response.${kIsWeb ? '\nCheck the browser console for errors.' : ''}",
        emptyString: () => "Empty string response.",
        emptyList: () => "Empty list response.",
        cancelled: () => "Request cancelled.",
        timeout: () => "A timeout occurred.",
        hostname: () => "Host name failed.",
        general: (m) => m,
        unknown: (u) => u.toString(),
      );

      return message;
    }

    return e.toString();
  }

  static String piToApiUrl(Pi pi) => pi.baseUrl + "/" + pi.apiPath;

  static String piToAdminUrl(Pi pi) => pi.baseUrl + pi.adminHome;

  static String piholeStatusToString(PiholeStatus status) => status.when(
        enabled: () => "Enabled",
        disabled: () => "Disabled",
        sleeping: (duration, startTime) => "Sleeping",
      );

  static final whitespaceFormatter =
      FilteringTextInputFormatter.deny(RegExp(r'\s\b|\b\s'));

  static String packageInfoToString(PackageInfo info, [bool build = true]) =>
      'v${info.version}${build && info.buildNumber.isNotEmpty ? '#${info.buildNumber}' : ''}'
          .trim();

  static String enumToString(dynamic x) =>
      x.toString().split('.').skip(1).join();

  static String numToPercentage(num x, [int fractionDigits = 1]) =>
      x.toStringAsFixed(fractionDigits) + '%';
}

extension Numx on num {
  toFormatted() => _numberFormat.format(this);
}

extension DashboardIDX on DashboardID {
  String get humanString {
    switch (this) {
      case DashboardID.versions:
        return 'Versions';
      case DashboardID.temperature:
        return 'Temperature';
      case DashboardID.memoryUsage:
        return 'Memory usage';
      case DashboardID.totalQueries:
        return 'Total queries';
      case DashboardID.queriesBlocked:
        return 'Queries blocked';
      case DashboardID.percentBlocked:
        return 'Blocked (%)';
      case DashboardID.domainsOnBlocklist:
        return 'Domains on blocklist';
      case DashboardID.forwardDestinations:
        return 'Upstream servers';
      case DashboardID.queryTypes:
        return 'Query types';
      case DashboardID.topPermittedDomains:
        return 'Domains';
    }
  }

  IconData get iconData {
    switch (this) {
      case DashboardID.versions:
        return KIcons.appVersion;
      case DashboardID.temperature:
        return KIcons.temperature;
      case DashboardID.memoryUsage:
        return KIcons.memoryUsage;
      case DashboardID.totalQueries:
        return KIcons.totalQueries;
      case DashboardID.queriesBlocked:
        return KIcons.queriesBlocked;
      case DashboardID.percentBlocked:
        return KIcons.percentBlocked;
      case DashboardID.domainsOnBlocklist:
        return KIcons.domainsOnBlocklist;
      case DashboardID.forwardDestinations:
        return KIcons.forwardDestinations;
      case DashboardID.queryTypes:
        return KIcons.queryTypes;
      case DashboardID.topPermittedDomains:
        return KIcons.domainsPermittedTile;
    }
  }
}

extension QueryStatusX on QueryStatus {
  String get description {
    switch (this) {
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
      case QueryStatus.BlockedWithExternalNull:
        return 'Blocked (external, NULL)';
      case QueryStatus.BlockedWithExternalNXRA:
        return 'Blocked (external, NXRA)';
      case QueryStatus.Unknown:
        return 'Unknown';
    }
  }

  IconData get iconData {
    switch (this) {
      case QueryStatus.Forwarded:
        return KIcons.forwarded;
      case QueryStatus.Cached:
        return KIcons.cached;
      case QueryStatus.BlockedWithGravity:
      case QueryStatus.BlockedWithRegexWildcard:
      case QueryStatus.BlockedWithBlacklist:
      case QueryStatus.BlockedWithExternalIP:
      case QueryStatus.BlockedWithExternalNull:
      case QueryStatus.BlockedWithExternalNXRA:
        return KIcons.blocked;
      case QueryStatus.Unknown:
      default:
        return KIcons.unknown;
    }
  }

  Color get color {
    switch (this) {
      case QueryStatus.Forwarded:
        return KColors.forwarded;
      case QueryStatus.Cached:
        return KColors.cached;
      case QueryStatus.BlockedWithGravity:
      case QueryStatus.BlockedWithRegexWildcard:
      case QueryStatus.BlockedWithBlacklist:
      case QueryStatus.BlockedWithExternalIP:
      case QueryStatus.BlockedWithExternalNull:
      case QueryStatus.BlockedWithExternalNXRA:
        return KColors.blocked;
      case QueryStatus.Unknown:
      default:
        return KColors.unknown;
    }
  }
}

final _hm = DateFormat.Hm();
final _hms = DateFormat.Hms();
final _jms = DateFormat('H:m:s.S');
final _full = DateFormat.yMd().addPattern(_hms.pattern);

String _twoDigits(int n) => n.toString().padLeft(2, "0");

extension DurationX on Duration {
  String get twoDigitSeconds => _twoDigits(inSeconds.remainder(60));
  String get twoDigitMinutes => _twoDigits(inMinutes.remainder(60));
  String get twoDigitHours => _twoDigits(inHours.remainder(60));

  String toHms() => [
        if (inHours > 0) ...['$inHours hours'],
        if (inMinutes % 60 != 0) ...['${inMinutes.remainder(60)} minutes'],
        if (inSeconds % 60 != 0) ...['${inSeconds.remainder(60)} seconds'],
      ].join(', ');
}

extension DateTimeX on DateTime {
  String beforeAfter(Duration duration) {
    final before = _hm.format(subtract(duration));
    final after = _hm.format(add(duration));
    return '$before - $after';
  }

  String get hm => _hm.format(this);

  String get hms => _hms.format(this);

  String get jms => _jms.format(this);

  String get full => _full.format(this);
}

extension StringX on String {
  String get capitalizeFirstLetter {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

extension TimeOfDayX on TimeOfDay {
  int get inMinutes => hour * 60 + minute;

  Duration absoluteDuration() {
    final now = TimeOfDay.now();
    if (inMinutes == now.inMinutes) {
      return Duration.zero;
    }

    int minutes = inMinutes - now.inMinutes;
    if (inMinutes < now.inMinutes) {
      minutes += 24 * 60;
    }
    return Duration(hours: (minutes / 60).floor(), minutes: minutes % 60);
  }
}
