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
    required int id,
    required String title,
    required String description,
    required int primaryColor,
    required int accentColor,
    required String baseUrl,
    required bool useSsl,
    required String apiPath,
    required int apiPort,
    required String apiToken,
    required bool apiTokenRequired,
    required bool allowSelfSignedCertificates,
    required String basicAuthenticationUsername,
    required String basicAuthenticationPassword,
    required String proxyUrl,
    required int proxyPort,
    required DashboardSettingsModel dashboardSettings,
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
    dashboardSettings: dashboardSettings.entity,
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
