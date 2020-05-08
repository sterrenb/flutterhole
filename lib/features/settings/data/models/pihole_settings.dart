import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/features/api/data/models/model.dart';
import 'package:flutterhole/features/settings/data/models/colors.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pihole_settings.freezed.dart';
part 'pihole_settings.g.dart';

@freezed
abstract class PiholeSettings extends MapModel with _$PiholeSettings {
  const factory PiholeSettings({
    // annotation
    @Default('Pihole') String title,
    @Default('') String description,
    @Default(Colors.blue)
    @JsonKey(fromJson: valueToMaterialColor, toJson: materialColorToValue)
        Color primaryColor,

    // host details
    @Default('http://pi.hole') String baseUrl,
    @Default('/admin/api.php') String apiPath,
    @Default(80) int apiPort,

    // authentication
    @Default('') String apiToken,
    @Default(false) bool allowSelfSignedCertificates,
    @Default('') String basicAuthenticationUsername,
    @Default('') String basicAuthenticationPassword,

    // proxy
    @Default('') String proxyUrl,
    @Default(8080) int proxyPort,
  }) = _PiholeSettings;

  factory PiholeSettings.fromJson(Map<String, dynamic> json) =>
      _$PiholeSettingsFromJson(json);
}
