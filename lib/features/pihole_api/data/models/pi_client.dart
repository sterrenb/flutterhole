import 'package:flutter/foundation.dart';
import 'package:flutterhole/features/pihole_api/data/models/model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pi_client.freezed.dart';
part 'pi_client.g.dart';

@freezed
abstract class PiClient extends MapModel implements _$PiClient {
  const PiClient._();

  const factory PiClient({
    String name,
    String ip,
  }) = _PiClient;

  factory PiClient.fromJson(Map<String, dynamic> json) =>
      _$PiClientFromJson(json);

  String get nameOrIp => (name?.isEmpty ?? true) ? ip : '${ip} (${name})';
}