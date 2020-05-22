import 'package:flutter/foundation.dart';
import 'package:flutterhole/core/convert.dart';
import 'package:flutterhole/features/pihole_api/data/models/model.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_client.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'over_time_data_clients.freezed.dart';

part 'over_time_data_clients.g.dart';

Map<DateTime, List<int>> _valueToHitsOverTime(dynamic value) {
  return (value as Map).cast<String, List<dynamic>>().map<DateTime, List<int>>(
      (String key, List<dynamic> hits) =>
          MapEntry(dateTimeFromPiholeString(key), List<int>.from(hits)));
}

dynamic _hitsOverTimeToValues(Map<DateTime, List<int>> hitsOverTime) {
  return hitsOverTime
      .map<String, dynamic>((DateTime key, List<int> hits) => MapEntry(
            piholeStringFromDateTime(key),
            hits,
          ));
}

@freezed
abstract class OverTimeDataClients extends MapModel with _$OverTimeDataClients {
  @JsonSerializable(explicitToJson: true)
  const factory OverTimeDataClients({
    @JsonKey(name: 'clients')
        List<PiClient> clients,
    @JsonKey(
      name: 'over_time',
      fromJson: _valueToHitsOverTime,
      toJson: _hitsOverTimeToValues,
    )
        Map<DateTime, List<int>> data,
  }) = _OverTimeDataClients;

  factory OverTimeDataClients.fromJson(Map<String, dynamic> json) =>
      _$OverTimeDataClientsFromJson(json);
}
