import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pihole_api/pihole_api.dart';

part 'settings_models.freezed.dart';
part 'settings_models.g.dart';

enum TemperatureReading {
  celcius,
  fahrenheit,
  kelvin,
}
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

const kWelcomeNotification = '''Welcome to FlutterHole!
''';

const defaultNotifications = [
  kWelcomeNotification,
  if (kDebugMode) ...['Running in debug mode.'],
  if (kIsWeb) ...[
    '''This is a demo. Only connections over HTTPS are allowed. You can use your own Pi-hole if it is setup with HTTPS.
To simulate a Pi-hole, use "example.com" in the Base URL.''',
  ],
];

const kDefaultThemeMode = kIsWeb ? ThemeMode.light : ThemeMode.system;

const defaultPiholes = kDebugMode
    ? [
        Pi(
          title: 'Demo',
          baseUrl: 'http://example.com',
          apiToken:
              String.fromEnvironment("PIHOLE_API_TOKEN", defaultValue: "token"),
        ),
        Pi(
          title: 'Home',
          baseUrl: 'http://10.0.1.5',
          apiToken:
              String.fromEnvironment('PIHOLE_API_TOKEN', defaultValue: ''),
        ),
        Pi(
          title: 'Secure',
          baseUrl: 'https://10.0.1.5',
        ),
        Pi(title: 'Pub', baseUrl: 'http://pub.dev', adminHome: ''),
        Pi(
            title: ('This one has very long name, but it should still work.'),
            baseUrl: 'https://pub.dev',
            adminHome: '/packages/pihole_api'),
      ]
    : [
        Pi(
          title: 'Demo',
          baseUrl: 'http://example.com',
          apiToken: 'token',
        )
      ];

@freezed
class UserPreferences with _$UserPreferences {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory UserPreferences({
    @Default(kDebugMode) bool devMode,
    @Default(kDebugMode) bool isDev,
    @Default(LogLevel.info) LogLevel logLevel,
    @Default(30) int updateFrequency,
    @Default(kDebugMode) bool showThemeToggle,
    @Default(kDefaultThemeMode) ThemeMode themeMode,
    @Default(FlexScheme.bigStone) FlexScheme flexScheme,
    @Default(TemperatureReading.celcius) TemperatureReading temperatureReading,
    @Default(defaultPiholes) List<Pi> piholes,
    @Default(0) int activeIndex,
    @Default([]) List<String> notificationsRead,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
}

@freezed
class DashboardTileConstraints with _$DashboardTileConstraints {
  const factory DashboardTileConstraints.count(
    int crossAxisCount,
    int mainAxisCount,
  ) = DashboardTileConstraintsCount;

  const factory DashboardTileConstraints.extent(
    int crossAxisCount,
    double mainAxisExtent,
  ) = DashboardTileConstraintsExtent;

  const factory DashboardTileConstraints.fit(
    int crossAxisCount,
  ) = DashboardTileConstraintsFit;

  factory DashboardTileConstraints.fromJson(Map<String, dynamic> json) =>
      _$DashboardTileConstraintsFromJson(json);
}

enum DashboardID {
  versions,
  temperature,
  memoryUsage,
  totalQueries,
  queriesBlocked,
  percentBlocked,
  domainsOnBlocklist,
  forwardDestinations,
  queryTypes,
  topPermittedDomains,
  queriesOverTime,
}

@freezed
class DashboardEntry with _$DashboardEntry {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory DashboardEntry({
    required DashboardID id,
    required bool enabled,
    required DashboardTileConstraints constraints,
  }) = _DashboardEntry;

  factory DashboardEntry.fromJson(Map<String, dynamic> json) =>
      _$DashboardEntryFromJson(json);

  static const defaultDashboard = [
    DashboardEntry(
        id: DashboardID.totalQueries,
        enabled: true,
        constraints: DashboardTileConstraints.count(4, 1)),
    DashboardEntry(
        id: DashboardID.queriesBlocked,
        enabled: true,
        constraints: DashboardTileConstraints.count(4, 1)),
    DashboardEntry(
        id: DashboardID.percentBlocked,
        enabled: true,
        constraints: DashboardTileConstraints.count(2, 2)),
    DashboardEntry(
        id: DashboardID.domainsOnBlocklist,
        enabled: true,
        constraints: DashboardTileConstraints.count(2, 2)),
    DashboardEntry(
        id: DashboardID.forwardDestinations,
        enabled: true,
        constraints: DashboardTileConstraints.count(4, 4)),
    DashboardEntry(
        id: DashboardID.temperature,
        enabled: true,
        constraints: DashboardTileConstraints.count(2, 1)),
    DashboardEntry(
        id: DashboardID.memoryUsage,
        enabled: true,
        constraints: DashboardTileConstraints.count(2, 1)),
    DashboardEntry(
        id: DashboardID.queryTypes,
        enabled: true,
        constraints: DashboardTileConstraints.count(4, 3)),
    DashboardEntry(
        id: DashboardID.versions,
        enabled: true,
        constraints: DashboardTileConstraints.count(4, 3)),
    DashboardEntry(
        id: DashboardID.queriesOverTime,
        enabled: true,
        constraints: DashboardTileConstraints.count(4, 3)),
  ];
}

@freezed
class Pi with _$Pi {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory Pi({
    @Default("Pi-hole") String title,
    @Default("https://pi.hole") String baseUrl,
    @Default("/admin/api.php") String apiPath,
    @Default(true) bool apiTokenRequired,
    @Default("") String apiToken,
    @Default(false) bool allowSelfSignedCertificates,
    @Default("/admin") String adminHome,
    @Default(DashboardEntry.defaultDashboard) List<DashboardEntry> dashboard,
  }) = _Pi;

  factory Pi.fromJson(Map<String, dynamic> json) => _$PiFromJson(json);

// late final String apiUrl = '$baseUrl$apiPath';
// late final String adminUrl = '$baseUrl$adminHome';
}

@freezed
class PingStatus with _$PingStatus {
  const factory PingStatus({
    required bool loading,
    required PiholeStatus status,
    Object? error,
  }) = _PingStatus;
}
