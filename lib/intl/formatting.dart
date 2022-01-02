import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:pihole_api/pihole_api.dart';

const JsonEncoder _jsonEncoder = JsonEncoder.withIndent('  ');

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
        invalidResponse: (response) => "The server responded with $response.",
        emptyString: () => "Empty string response.",
        emptyList: () => "Empty list response.",
        cancelled: () => "Request cancelled.",
        timeout: () => "A timeout occurred.",
        hostname: () => "Host name failed.",
        general: (m) => "Something went wrong. $m.",
        unknown: (u) => u.toString(),
      );

      return message;
    }

    return e.toString();
  }

  static String piToApiUrl(Pi pi) => pi.baseUrl + "/" + pi.apiPath;
  static String piToAdminUrl(Pi pi) => pi.baseUrl + pi.adminHome;

  static String piholeStatusToString(PiholeStatus status) => status.when(
        loading: () => "Loading",
        enabled: () => "Enabled",
        disabled: () => "Disabled",
        sleeping: (duration, startTime) => "Sleeping",
        failure: (f) => "Failure",
      );

  static final whitespaceFormatter =
      FilteringTextInputFormatter.deny(RegExp(r'\s\b|\b\s'));
}
