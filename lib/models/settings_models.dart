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
  }) = _Pi;

  factory Pi.fromJson(Map<String, dynamic> json) => _$PiFromJson(json);
}
