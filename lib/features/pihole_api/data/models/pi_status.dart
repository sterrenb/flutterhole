import 'package:flutter/foundation.dart';
import 'package:flutterhole/features/pihole_api/data/models/model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pi_status.freezed.dart';
part 'pi_status.g.dart';

enum PiStatusEnum {
  enabled,
  disabled,
  unknown,
}

@freezed
abstract class PiStatus extends MapModel with _$PiStatus {
  const factory PiStatus({
    @JsonKey(
      name: 'status',
    ) PiStatusEnum status,
  }) = _PiStatus;

  factory PiStatus.fromJson(Map<String, dynamic> json) =>
      _$PiStatusFromJson(json);
}
