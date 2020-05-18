import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/features/pihole_api/data/models/model.dart';
import 'package:flutterhole/features/settings/data/models/colors.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pihole_settings.freezed.dart';
part 'pihole_settings.g.dart';

@freezed
abstract class PiholeSettings extends MapModel implements _$PiholeSettings {
  const PiholeSettings._();

  const factory PiholeSettings({
    // annotation
    @Default('Pihole')
        String title,
    @Default('')
        String description,
    @Default(Color.fromRGBO(33, 150, 243, 1)) // i.e. `Colors.blue`
    @JsonKey(fromJson: colorFromHex, toJson: colorToHex)
        Color primaryColor,
    @Default(Color.fromRGBO(244, 67, 54, 1)) // i.e. `Colors.red`
    @JsonKey(fromJson: colorFromHex, toJson: colorToHex) Color accentColor,

    // host details
    @Default('http://pi.hole') String baseUrl,
    @Default('/admin/api.php') String apiPath,
    @Default(80) int apiPort,

    // authentication
    @Default('') String apiToken,
    @Default(true) bool apiTokenRequired,
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
