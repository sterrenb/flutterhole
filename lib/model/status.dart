// To parse this JSON data, do
//
//     final status = statusFromJson(jsonString);

import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

String statusToJson(Status data) => json.encode(data.toJson());

/// The API model for http://pi.hole/admin/api.php?status.
class Status extends Equatable {
  final bool enabled;

  bool get disabled => !enabled;

  Status({
    @required this.enabled,
  }) : super([enabled]);

  factory Status.fromMap(Map<String, dynamic> json) => Status(
        enabled: json["status"] == "enabled",
      );

  factory Status.fromString(String str) => Status.fromMap(json.decode(str));

  Map<String, dynamic> toJson() => {
        "status": enabled ? "enabled" : "disabled",
      };

  @override
  String toString() => 'enabled: $enabled';
}
