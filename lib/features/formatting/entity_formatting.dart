import 'dart:convert';

import 'package:flutterhole_web/features/entities/settings_entities.dart';
import 'package:flutterhole_web/features/formatting/date_formatting.dart';
import 'package:flutterhole_web/features/models/settings_models.dart';
import 'package:pihole_api/pihole_api.dart';

const importEntityFormatting = null;

const JsonEncoder _jsonEncoder = JsonEncoder.withIndent('  ');

extension MapX on Map<String, dynamic> {
  String toJsonString() => _jsonEncoder.convert(this);
}

extension PiX on Pi {
  String toReadableJson() {
    final model = PiModel.fromEntity(this);
    final input = model.toJson();
    // if (input.containsKey('apiToken')) input['apiToken'] = '<token>';
    input.update('apiToken', (value) => '<token>');
    // input.update('dashboardSettings', (value) {
    //   if (model.dashboardSettings != null) {
    //     return model.dashboardSettings!.toJson()
    //       ..update(
    //           'entries',
    //           (value) => (value as List<DashboardEntryModel>)
    //               .map((e) => e.id.toString().replaceFirst('DashboardID.', ''))
    //               .toList());
    //   }
    // });
    return input.toJsonString();
  }
}

extension QueryItemX on QueryItem {
  String toReadableJson() {
    final model = QueryItemModel(
      timestamp: timestamp,
      queryType: queryType,
      domain: domain,
      clientName: clientName,
      queryStatus: queryStatus,
      dnsSecStatus: dnsSecStatus,
      delta: delta,
    );

    final input = model.toJson();

    input.update('timestamp', (value) => timestamp.full);

    return input.toJsonString();
  }
}

extension UserPreferencesX on UserPreferences {
  Map<String, dynamic> toReadableMap() => UserPreferencesModel.fromEntity(this)
      .toJson()
        ..update('temperatureReading',
            (value) => value.toString().replaceFirst('TemperatureReading.', ''))
        ..update('themeMode',
            (value) => value.toString().replaceFirst('ThemeMode.', ''));
}

const String hostHelp = 'Make sure your host details are correct.';

extension PiholeApiFailureX on PiholeApiFailure {
  String get title => when(
        notFound: () => 'Not found',
        notAuthenticated: () => 'Not authenticated',
        invalidResponse: (statusCode) => 'Invalid response',
        emptyString: () => 'Empty response',
        emptyList: () => 'Empty response',
        cancelled: () => 'Cancelled',
        timeout: () => 'Timeout',
        hostname: () => 'Hostname',
        general: (message) => 'Error',
        unknown: (e) => 'Unknown',
      );

  String get description {
    return when(
      notFound: () => 'The requested resource was not found.\n\n$hostHelp',
      notAuthenticated: () =>
          'Authentication failed.\n\nMake sure you have entered the correct API token.',
      invalidResponse: (statusCode) => 'Invalid response $statusCode.',
      emptyString: () =>
          'Empty response. This typically happens when the API token is missing/invalid.\n\n$hostHelp',
      emptyList: () =>
          'Empty list response. This typically happens when the API token is missing/invalid.\n\n$hostHelp',
      cancelled: () => 'Cancelled by application.',
      timeout: () =>
          'A timeout occurred.\n\n$hostHelp\n\nConsider lowering the update frequency.',
      hostname: () =>
          'Hostname not found.\n\nIf your domain is "pi.hole", try using the IP address of your Pi-hole instead (e.g. "192.168.1.5").',
      general: (message) => 'Something went wrong: $message',
      unknown: (e) => 'Unknown: ${e.toString()}',
    );
  }
}
