import 'dart:convert';

import 'package:flutterhole/model/serializable.dart';
import 'package:meta/meta.dart';

/// The API model for http://pi.hole/admin/api.php?status.
class Status extends Serializable {
  Status({
    @required this.enabled,
  });

  final bool enabled;

  @override
  List<Object> get props => [enabled];

  bool get disabled => !enabled;

  factory Status.fromJson(Map<String, dynamic> json) =>
      Status(
        enabled: json["status"] == "enabled",
      );

  factory Status.fromString(String str) => Status.fromJson(json.decode(str));

  @override
  Map<String, dynamic> toJson() => {
    "status": enabled ? "enabled" : "disabled",
  };
}
