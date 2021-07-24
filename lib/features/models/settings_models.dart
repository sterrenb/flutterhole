import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/entities/logging_entities.dart';
import 'package:flutterhole_web/features/entities/settings_entities.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_models.freezed.dart';
part 'settings_models.g.dart';

@freezed
class PiModel with _$PiModel {
  PiModel._();

  factory PiModel({
    @Default(0) int id,
    @Default('FlutterHole') String title,
    @Default('') String description,
    @Default(4294940672) int primaryColor,
    @Default(4294945600) int accentColor,
    @Default('pi.hole') String baseUrl,
    @Default(false) bool useSsl,
    @Default('/admin/api.php') String apiPath,
    @Default(80) int apiPort,
    @Default('3f4fa74468f336df5c4cf1d343d160f8948375732f82ea1a057138ae7d35055c')
        String apiToken,
    @Default(true) bool apiTokenRequired,
    @Default(false) bool allowSelfSignedCertificates,
    @Default('') String basicAuthenticationUsername,
    @Default('') String basicAuthenticationPassword,
    @Default('') String proxyUrl,
    @Default(8080) int proxyPort,
    DashboardSettingsModel? dashboardSettings,
  }) = _PiModel;

  factory PiModel.fromJson(Map<String, dynamic> json) =>
      _$PiModelFromJson(json);

  factory PiModel.fromEntity(Pi pi) => PiModel(
        id: pi.id,
        title: pi.title,
        description: pi.description,
        primaryColor: pi.primaryColor.value,
        accentColor: pi.accentColor.value,
        dashboardSettings:
            DashboardSettingsModel.fromEntity(pi.dashboardSettings),
        baseUrl: pi.baseUrl,
        useSsl: pi.useSsl,
        apiPath: pi.apiPath,
        apiPort: pi.apiPort,
        apiToken: pi.apiToken,
        apiTokenRequired: pi.apiTokenRequired,
        allowSelfSignedCertificates: pi.allowSelfSignedCertificates,
        basicAuthenticationUsername: pi.basicAuthenticationUsername,
        basicAuthenticationPassword: pi.basicAuthenticationPassword,
        proxyUrl: pi.proxyUrl,
        proxyPort: pi.proxyPort,
      );

  late final Pi entity = Pi(
    id: id,
    title: title,
    description: description,
    primaryColor: Color(primaryColor),
    accentColor: Color(accentColor),
    dashboardSettings:
        (dashboardSettings ?? DashboardSettingsModel.initial()).entity,
    baseUrl: baseUrl,
    useSsl: useSsl,
    apiPath: apiPath,
    apiPort: apiPort,
    apiToken: apiToken,
    apiTokenRequired: apiTokenRequired,
    allowSelfSignedCertificates: allowSelfSignedCertificates,
    basicAuthenticationUsername: basicAuthenticationUsername,
    basicAuthenticationPassword: basicAuthenticationPassword,
    proxyUrl: proxyUrl,
    proxyPort: proxyPort,
  );
}

DashboardTileConstraints idToConstraints(DashboardID id) {
  switch (id) {
    case DashboardID.selectTiles:
      return const DashboardTileConstraints.count(4, 1);
    case DashboardID.totalQueries:
      return const DashboardTileConstraints.count(4, 1);
    case DashboardID.queriesBlocked:
      return const DashboardTileConstraints.count(4, 1);
    case DashboardID.percentBlocked:
      return const DashboardTileConstraints.count(4, 1);
    case DashboardID.domainsOnBlocklist:
      return const DashboardTileConstraints.count(4, 1);
    case DashboardID.queriesOverTime:
      return const DashboardTileConstraints.fit(8);
    case DashboardID.clientActivity:
      return const DashboardTileConstraints.fit(8);
    case DashboardID.memory:
      return const DashboardTileConstraints.count(2, 2);
    case DashboardID.queryTypes:
      return const DashboardTileConstraints.count(4, 2);
    case DashboardID.forwardDestinations:
      return const DashboardTileConstraints.count(4, 2);
    case DashboardID.topPermittedDomains:
      return const DashboardTileConstraints.fit(4);
    case DashboardID.topBlockedDomains:
      return const DashboardTileConstraints.fit(4);
    case DashboardID.versions:
      return const DashboardTileConstraints.fit(4);
    case DashboardID.logs:
      return const DashboardTileConstraints.extent(
          4, (kLogsDashboardCacheLength + 2) * kToolbarHeight);
    case DashboardID.temperature:
      return const DashboardTileConstraints.count(2, 2);

    // default:
    //   throw StateError('unsupported DashboardID $id');
  }
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

  static final Map<DashboardID, DashboardTileConstraints> defaults = DashboardID
      .values
      .asMap()
      .map((index, id) => MapEntry(id, idToConstraints(id)));
}

@freezed
class DashboardEntryModel with _$DashboardEntryModel {
  DashboardEntryModel._();

  factory DashboardEntryModel({
    required String id,
    required bool enabled,
    required DashboardTileConstraints constraints,
  }) = _DashboardEntryModel;

  factory DashboardEntryModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardEntryModelFromJson(json);

  factory DashboardEntryModel.fromEntity(DashboardEntry entry) =>
      DashboardEntryModel(
        id: entry.id.toString(),
        enabled: entry.enabled,
        constraints: entry.constraints,
      );

// late final DashboardEntry entity = DashboardEntry(
//   id: id,
//   enabled: enabled,
//   constraints: constraints,
// );
}

@freezed
class DashboardSettingsModel with _$DashboardSettingsModel {
  DashboardSettingsModel._();

  factory DashboardSettingsModel({
    required List<DashboardEntryModel> entries,
  }) = _DashboardSettingsModel;

  factory DashboardSettingsModel.fromEntity(DashboardSettings settings) =>
      DashboardSettingsModel(
          entries: settings.entries
              .map((e) => DashboardEntryModel.fromEntity(e))
              .toList());

  factory DashboardSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardSettingsModelFromJson(json);

  factory DashboardSettingsModel.initial() => DashboardSettingsModel(entries: [
        ...DashboardID.values.sublist(0, 4).map(
              (e) => DashboardEntryModel(
                  id: e.toString(),
                  enabled: true,
                  constraints: DashboardTileConstraints.defaults[e]!),
            )
      ]);

  late final DashboardSettings entity = DashboardSettings(
      entries: entries
          .where((model) => dashboardIDStrings.contains(model.id))
          .map((model) => DashboardEntry(
                id: DashboardID.values
                    .elementAt(dashboardIDStrings.indexOf(model.id)),
                enabled: model.enabled,
                constraints: model.constraints,
              ))
          .toList());
}

@freezed
class UserPreferencesModel with _$UserPreferencesModel {
  UserPreferencesModel._();

  factory UserPreferencesModel({
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default(TemperatureReading.celcius) TemperatureReading temperatureReading,
    @Default(40) double temperatureMin,
    @Default(60) double temperatureMax,
    @Default(60) int updateFrequency,
    @Default(false) bool devMode,
    @Default(false) bool useThemeToggle,
    @Default(LogLevel.warning) LogLevel logLevel,
    @Default(false) bool useAggressiveFetching,
    @Default(100) int queryLogMax,
    @Default(null) DateTime? lastStartup,
  }) = _UserPreferencesModel;

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesModelFromJson(json);

  factory UserPreferencesModel.fromEntity(UserPreferences entity) =>
      UserPreferencesModel(
        themeMode: entity.themeMode,
        temperatureReading: entity.temperatureReading,
        temperatureMin: entity.temperatureMin,
        temperatureMax: entity.temperatureMax,
        updateFrequency: entity.updateFrequency.inSeconds,
        devMode: entity.devMode,
        useThemeToggle: entity.useThemeToggle,
        logLevel: entity.logLevel,
        useAggressiveFetching: entity.useAggressiveFetching,
        queryLogMax: entity.queryLogMax,
      );

  late final UserPreferences entity = UserPreferences(
    themeMode: ThemeMode.values.firstWhere((element) => element == themeMode),
    temperatureReading: TemperatureReading.values
        .firstWhere((element) => element == temperatureReading),
    temperatureMin: temperatureMin,
    temperatureMax: temperatureMax,
    updateFrequency: Duration(seconds: updateFrequency),
    devMode: devMode,
    useThemeToggle: useThemeToggle,
    logLevel: logLevel,
    useAggressiveFetching: useAggressiveFetching,
    queryLogMax: queryLogMax,
    lastStartup: lastStartup,
  );
}
