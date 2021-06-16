import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutterhole_web/features/entities/api_entities.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';

part 'settings_entities.freezed.dart';

/// TODOs when adding a new tile:
/// 1. append a memorable value to [DashboardID].
/// 2. create the new widget.
/// 3. add the widget to [DashboardIDX.widget].
/// 4. add an icon to [DashboardIDI.iconData].
///   - optionally add a canonical icon to [KIcons].
/// 5. add the size constraints to [staggeredTile].
/// 6. run the build_runner to update the [DashboardID] json serialization:
///   `$ flutter pub run build_runner build`
enum DashboardID {
  SelectTiles,
  TotalQueries,
  QueriesBlocked,
  PercentBlocked,
  DomainsOnBlocklist,
  QueriesBarChart,
  ClientActivityBarChart,
  Temperature,
  Memory,
  QueryTypes,
  ForwardDestinations,
  TopPermittedDomains,
  TopBlockedDomains,
  Versions,
  Logs,
  TempTile,
}

@freezed
class SettingsState with _$SettingsState {
  SettingsState._();

  factory SettingsState({
    required List<Pi> allPis,
    required int activeId,
    required UserPreferences preferences,
    required bool dev,
  }) = _SettingsState;

  late final Pi active = allPis.firstWhere((element) {
    return element.id == activeId;
  });
}

@freezed
class DashboardEntry with _$DashboardEntry {
  DashboardEntry._();

  factory DashboardEntry({
    required DashboardID id,
    required bool enabled,
  }) = _DashboardEntry;
}

@freezed
class DashboardSettings with _$DashboardSettings {
  DashboardSettings._();

  factory DashboardSettings({
    required List<DashboardEntry> entries,
  }) = _DashboardSettings;

  factory DashboardSettings.initial() => DashboardSettings(entries: [
        ...DashboardID.values
            .map<DashboardEntry>((e) => DashboardEntry(id: e, enabled: true))
            .toList()
            .sublist(0, DashboardID.values.length ~/ 2),
        DashboardEntry(id: DashboardID.SelectTiles, enabled: true),
      ]);

  late final List<DashboardID> keys = entries.map((e) => e.id).toList();
}

enum TemperatureReading {
  celcius,
  fahrenheit,
  kelvin,
}

@freezed
class UserPreferences with _$UserPreferences {
  UserPreferences._();

  factory UserPreferences({
    required ThemeMode themeMode,
    required TemperatureReading temperatureReading,
    required double temperatureMin,
    required double temperatureMax,
    required Duration updateFrequency,
    required bool devMode,
  }) = _UserPreferences;

  factory UserPreferences.initial() => UserPreferences(
        themeMode: ThemeMode.system,
        temperatureReading: TemperatureReading.celcius,
        temperatureMin: 40.0,
        temperatureMax: 60.0,
        updateFrequency: Duration(seconds: 30),
        devMode: false,
      );
}

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

extension LogLevelX on LogLevel {
  Level get level {
    switch (this) {
      case LogLevel.debug:
        return Level.FINE;
      case LogLevel.info:
        return Level.INFO;
      case LogLevel.warning:
        return Level.WARNING;
      case LogLevel.error:
        return Level.SEVERE;
    }
  }
}

@freezed
class LogCall with _$LogCall {
  LogCall._();

  factory LogCall({
    required String source,
    required LogLevel level,
    required Object message,
    Object? error,
    StackTrace? stackTrace,
  }) = _LogCall;
}

@freezed
class PiColorTheme with _$PiColorTheme {
  PiColorTheme._();

  factory PiColorTheme({
    required Color success,
    required Color info,
    required Color onInfo,
    required Color debug,
    required Color onDebug,
    required Color warning,
    required Color onWarning,
    required Color error,
    required Color onError,
    required Color totalQueries,
    required Color queriesBlocked,
    required Color percentBlocked,
    required Color domainsOnBlocklist,
    required Color temperatureLow,
    required Color temperatureMed,
    required Color temperatureHigh,
  }) = _PiColorTheme;

  factory PiColorTheme.light() => PiColorTheme(
        success: Colors.green,
        info: Colors.blue,
        onInfo: Colors.white,
        debug: Colors.blueGrey,
        onDebug: Colors.white,
        warning: Colors.orange,
        onWarning: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        totalQueries: Colors.green,
        queriesBlocked: Colors.blue,
        percentBlocked: Colors.orange,
        domainsOnBlocklist: Colors.redAccent,
        temperatureLow: Colors.green,
        temperatureMed: Colors.orange,
        temperatureHigh: Colors.red,
      );

  factory PiColorTheme.dark() => PiColorTheme.light().copyWith(
        warning: Color(0xFFB1720C),
        error: Color(0xFF913225),
        totalQueries: Color(0xFF005C32),
        queriesBlocked: Color(0xFF007997),
        percentBlocked: Color(0xFFB1720C),
        domainsOnBlocklist: Color(0xFF913225),
        temperatureLow: Color(0xFF005C32),
        temperatureMed: Color(0xFFB1720C),
        temperatureHigh: Color(0xFF913225),
      );

  static PiColorTheme of(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.light
        ? PiColorTheme.light()
        : PiColorTheme.dark();
  }
}
