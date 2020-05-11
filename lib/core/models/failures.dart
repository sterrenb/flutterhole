import 'package:flutter/foundation.dart';
import 'package:flutterhole/features/pihole_api/data/models/model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

part 'failures.g.dart';

@freezed
abstract class Failure extends MapModel with _$Failure {
  const factory Failure([
    String message,
    Object error,
  ]) = _Failure;

  factory Failure.fromJson(Map<String, dynamic> json) =>
      _$FailureFromJson(json);
}
