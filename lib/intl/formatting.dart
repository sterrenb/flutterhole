import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
            "The server responded with status code $response.",
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
      'v${info.version}${build ? '#${info.buildNumber}' : ''}'.trim();
}

extension Numx on num {
  toFormatted() => _numberFormat.format(this);
}

extension DashboardIDX on DashboardID {
  String toReadable() {
    switch (this) {
      case DashboardID.versions:
        return 'Versions';
      case DashboardID.temperature:
        return 'Temperature';
      case DashboardID.memoryUsage:
        return 'Memory';
      case DashboardID.totalQueries:
        return 'Total queries';
      case DashboardID.queriesBlocked:
        return 'Queries blocked';
      case DashboardID.percentBlocked:
        return 'Blocked';
      case DashboardID.domainsOnBlocklist:
        return 'Domains';
      case DashboardID.forwardDestinations:
        return 'Forward destinations';
      case DashboardID.topPermittedDomains:
        return 'Domains';
    }
  }
}
