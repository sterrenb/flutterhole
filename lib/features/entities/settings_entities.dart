import 'package:flutter/material.dart';
import 'package:flutterhole_web/features/entities/logging_entities.dart';
import 'package:flutterhole_web/features/models/settings_models.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_entities.freezed.dart';

/// TODOs when adding a new tile:
/// 1. append a memorable value to [DashboardID].
///   - optionally set it as devOnly in [DevDashboardID].
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
class DashboardEntry with _$DashboardEntry {
  DashboardEntry._();

  factory DashboardEntry({
    required DashboardID id,
    required bool enabled,
    required DashboardTileConstraints constraints,
  }) = _DashboardEntry;
}

extension DevDashboardID on DashboardID {
  bool get devOnly => [
        DashboardID.Logs,
        DashboardID.Versions,
        DashboardID.TempTile,
      ].contains(this);
}

@freezed
class Pi with _$Pi {
  Pi._();

  factory Pi({
    // annotation
    required int id,
    required String title,
    required String description,
    required Color primaryColor,
    required Color accentColor,

    // host details
    required String baseUrl,
    required bool useSsl,
    required String apiPath,
    required int apiPort,

    // authentication
    required String apiToken,
    required bool apiTokenRequired,
    required bool allowSelfSignedCertificates,
    required String basicAuthenticationUsername,
    required String basicAuthenticationPassword,

    // proxy
    required String proxyUrl,
    required int proxyPort,
    required DashboardSettings dashboardSettings,
  }) = _Pi;

  // late final String host = '$baseUrl:$apiPort';

  late final String dioBase =
      '${useSsl ? 'https://' : 'http://'}$baseUrl${(apiPort == 80 && useSsl == false) || (apiPort == 443 && useSsl == true) ? '' : ':$apiPort'}';

  late final String baseApiUrl = '$dioBase/$apiPath';

  // TODO add to editable fields
  late final String adminHome = '/admin';
}

@freezed
class SettingsState with _$SettingsState {
  SettingsState._();

  factory SettingsState({
    required List<Pi> allPis,
    required int activeId,
    required UserPreferences userPreferences,
  }) = _SettingsState;

  // TODO this can still throw
  late final Pi active = allPis.firstWhere((element) {
    return element.id == activeId;
  });

  late final bool dev = userPreferences.devMode;
}

@freezed
class DashboardSettings with _$DashboardSettings {
  DashboardSettings._();

  factory DashboardSettings({
    required List<DashboardEntry> entries,
  }) = _DashboardSettings;

  factory DashboardSettings.initial() => DashboardSettings(entries: [
        ...DashboardID.values
            .map<DashboardEntry>((e) => DashboardEntry(
                id: e,
                enabled: true,
                constraints: DashboardTileConstraints.defaults[e]!))
            .toList(),
        DashboardEntry(
            id: DashboardID.SelectTiles,
            enabled: true,
            constraints:
                DashboardTileConstraints.defaults[DashboardID.SelectTiles]!),
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
    required bool useThemeToggle,
    required LogLevel logLevel,
    required bool useAggressiveFetching,
    required int queryLogMax,
    required DateTime? lastStartup,
  }) = _UserPreferences;

  late final bool firstUse = lastStartup == null;
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
        totalQueries: Color(0xFF1B5E20),
        // totalQueries: Color(0xFF005C32),
        queriesBlocked: Color(0xFF007997),
        percentBlocked: Color(0xFFB1720C),
        domainsOnBlocklist: Color(0xFF913225),
        temperatureLow: Color(0xFF1B5E20),
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
