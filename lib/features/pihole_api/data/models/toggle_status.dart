import 'package:flutter/foundation.dart';
import 'package:flutterhole/features/pihole_api/data/models/model.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'toggle_status.freezed.dart';

part 'toggle_status.g.dart';

@freezed
abstract class ToggleStatus extends MapModel with _$ToggleStatus {
  const factory ToggleStatus({
    PiStatusEnum status,
  }) = _ToggleStatus;

  factory ToggleStatus.fromJson(Map<String, dynamic> json) =>
      _$ToggleStatusFromJson(json);
}
