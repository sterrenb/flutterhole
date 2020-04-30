import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutterhole/features/api/data/models/model.dart';

part 'pi_client.freezed.dart';
part 'pi_client.g.dart';

@freezed
abstract class PiClient extends Model with _$PiClient {
  const factory PiClient({
    String title,
    String ip,
  }) = _PiClient;

  factory PiClient.fromJson(Map<String, dynamic> json) =>
      _$PiClientFromJson(json);
}