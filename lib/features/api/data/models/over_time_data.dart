import 'package:flutter/foundation.dart';
import 'package:flutterhole/features/api/data/models/model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'over_time_data.freezed.dart';

part 'over_time_data.g.dart';

Map<DateTime, int> _valueToDatesOverTime(dynamic value) {
  return (value as Map).cast<String, num>().map<DateTime, int>(
      (String key, num value) => MapEntry(
          DateTime.fromMillisecondsSinceEpoch(int.tryParse(key) * 100), value));
}

dynamic _datesOverTimeToValues(Map<DateTime, int> dates) {
  return dates.map<String, dynamic>((DateTime key, int value) => MapEntry(
        '${key.millisecondsSinceEpoch ~/ 100}',
        value,
      ));
}

/// {{ base_url  }}?overTimeData10mins
@freezed
abstract class OverTimeData extends MapModel with _$OverTimeData {
  const factory OverTimeData({
    @JsonKey(
      name: 'domains_over_time',
      fromJson: _valueToDatesOverTime,
      toJson: _datesOverTimeToValues,
    )
        Map<DateTime, int> domainsOverTime,
    @JsonKey(
      name: 'ads_over_time',
      fromJson: _valueToDatesOverTime,
      toJson: _datesOverTimeToValues,
    )
        Map<DateTime, int> adsOverTime,
  }) = _OverTimeData;

  factory OverTimeData.fromJson(Map<String, dynamic> json) =>
      _$OverTimeDataFromJson(json);
}
