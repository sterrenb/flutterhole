import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pi_extras.freezed.dart';
part 'pi_extras.g.dart';

@freezed
abstract class PiExtras with _$PiExtras {
  const factory PiExtras({
    num temperature,
    List<num> load,
    num memoryUsage,
  }) = _PiExtras;

  factory PiExtras.fromJson(Map<String, dynamic> json) =>
      _$PiExtrasFromJson(json);
}