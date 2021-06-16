import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutterhole_web/features/entities/api_entities.dart';
import 'package:flutterhole_web/features/entities/settings_entities.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_models.freezed.dart';
part 'settings_models.g.dart';

@freezed
class PiModel with _$PiModel {
  PiModel._();

  factory PiModel({
    @Default(0) int id,
    @Default("Pi-hole") String title,
    @Default("") String description,
    @Default(4284955319) int primaryColor,
    @Default(4294945600) int accentColor,
    @Default("pi.hole") String baseUrl,
    @Default(false) bool useSsl,
    @Default("/admin/api.php") String apiPath,
    @Default(80) int apiPort,
    @Default("3f4fa74468f336df5c4cf1d343d160f8948375732f82ea1a057138ae7d35055c")
        String apiToken,
    @Default(true) bool apiTokenRequired,
    @Default(false) bool allowSelfSignedCertificates,
    @Default("") String basicAuthenticationUsername,
    @Default("") String basicAuthenticationPassword,
    @Default("") String proxyUrl,
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

@freezed
class DashboardEntryModel with _$DashboardEntryModel {
  DashboardEntryModel._();

  factory DashboardEntryModel({
    required DashboardID id,
    required bool enabled,
  }) = _DashboardEntryModel;

  factory DashboardEntryModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardEntryModelFromJson(json);

  factory DashboardEntryModel.fromEntity(DashboardEntry entry) =>
      DashboardEntryModel(
        id: entry.id,
        enabled: entry.enabled,
      );

  late final DashboardEntry entity = DashboardEntry(id: id, enabled: enabled);
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
        ...DashboardID.values
            .sublist(0, 4)
            .map((e) => DashboardEntryModel(id: e, enabled: true))
      ]);

  late final DashboardSettings entity =
      DashboardSettings(entries: entries.map((e) => e.entity).toList());
}

@freezed
class UserPreferencesModel with _$UserPreferencesModel {
  UserPreferencesModel._();

  factory UserPreferencesModel({
    @Default('ThemeMode.system') String themeMode,
    @Default('TemperatureReading.celcius') String temperatureReading,
    @Default(30) double temperatureMin,
    @Default(70) double temperatureMax,
    @Default(60) int updateFrequency,
    @Default(false) bool devMode,
  }) = _UserPreferencesModel;

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesModelFromJson(json);

  factory UserPreferencesModel.fromEntity(UserPreferences entity) =>
      UserPreferencesModel(
        themeMode: entity.themeMode.toString(),
        temperatureReading: entity.temperatureReading.toString(),
        temperatureMin: entity.temperatureMin,
        temperatureMax: entity.temperatureMax,
        updateFrequency: entity.updateFrequency.inSeconds,
        devMode: entity.devMode,
      );

  late final UserPreferences entity = UserPreferences(
    themeMode: ThemeMode.values
        .firstWhere((element) => element.toString() == themeMode),
    temperatureReading: TemperatureReading.values
        .firstWhere((element) => element.toString() == temperatureReading),
    temperatureMin: temperatureMin,
    temperatureMax: temperatureMax,
    updateFrequency: Duration(seconds: updateFrequency),
    devMode: devMode,
  );
}

@freezed
class DeveloperPreferencesModel with _$DeveloperPreferencesModel {
  DeveloperPreferencesModel._();

  factory DeveloperPreferencesModel({
    @Default(false) bool useThemeToggle,
    @Default(LogLevel.warning) LogLevel logLevel,
    @Default(false) bool useAggressiveFetching,
  }) = _DeveloperPreferencesModel;

  factory DeveloperPreferencesModel.fromJson(Map<String, dynamic> json) =>
      _$DeveloperPreferencesModelFromJson(json);

  factory DeveloperPreferencesModel.fromEntity(DeveloperPreferences entity) =>
      DeveloperPreferencesModel(
        useThemeToggle: entity.useThemeToggle,
        logLevel: entity.logLevel,
        useAggressiveFetching: entity.useAggressiveFetching,
      );

  late final DeveloperPreferences entity = DeveloperPreferences(
    useThemeToggle: useThemeToggle,
    logLevel: logLevel,
    useAggressiveFetching: useAggressiveFetching,
  );
}
