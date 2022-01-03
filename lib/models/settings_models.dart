import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

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

@freezed
class UserPreferences with _$UserPreferences {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory UserPreferences({
    @Default(false) bool devMode,
    @Default(LogLevel.info) LogLevel logLevel,
    @Default(30) int updateFrequency,
    @Default(false) bool showThemeToggle,
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default(FlexScheme.mallardGreen) FlexScheme flexScheme,
    @Default(TemperatureReading.fahrenheit)
        TemperatureReading temperatureReading,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
}

@freezed
class DashboardTileConstraints with _$DashboardTileConstraints {
  const factory DashboardTileConstraints.count(
    int crossAxisCount,
    int mainAxisCount,
  ) = _Count;

  const factory DashboardTileConstraints.extent(
    int crossAxisCount,
    double mainAxisExtent,
  ) = _Extent;

  const factory DashboardTileConstraints.fit(
    int crossAxisCount,
  ) = _Fit;

  factory DashboardTileConstraints.fromJson(Map<String, dynamic> json) =>
      _$DashboardTileConstraintsFromJson(json);
}

enum DashboardID {
  versions,
  totalQueries,
  queriesBlocked,
  percentBlocked,
  domainsOnBlocklist,
  forwardDestinations,
  topPermittedDomains,
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

  static const all = [
    DashboardEntry(
        id: DashboardID.versions,
        enabled: true,
        constraints: DashboardTileConstraints.count(4, 2)),
    DashboardEntry(
        id: DashboardID.totalQueries,
        enabled: true,
        constraints: DashboardTileConstraints.count(4, 1)),
    DashboardEntry(
        id: DashboardID.queriesBlocked,
        enabled: false,
        constraints: DashboardTileConstraints.count(4, 1)),
    DashboardEntry(
        id: DashboardID.percentBlocked,
        enabled: true,
        constraints: DashboardTileConstraints.count(2, 1)),
    DashboardEntry(
        id: DashboardID.domainsOnBlocklist,
        enabled: true,
        constraints: DashboardTileConstraints.count(2, 1)),
    DashboardEntry(
        id: DashboardID.forwardDestinations,
        enabled: true,
        constraints: DashboardTileConstraints.extent(2, 500)),
    DashboardEntry(
        id: DashboardID.topPermittedDomains,
        enabled: true,
        constraints: DashboardTileConstraints.fit(2)),
  ];
}

@freezed
class Pi with _$Pi {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory Pi({
    @Default("My Pi-hole") String title,
    @Default("http://10.0.1.5") String baseUrl,
    @Default("/admin/api.php") String apiPath,
    @Default(true) bool apiTokenRequired,
    @Default("token") String apiToken,
    @Default(false) bool allowSelfSignedCertificates,
    @Default("/admin") String adminHome,
    @Default(DashboardEntry.all) List<DashboardEntry> dashboard,
  }) = _Pi;

  factory Pi.fromJson(Map<String, dynamic> json) => _$PiFromJson(json);
}
