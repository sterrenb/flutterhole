import 'dart:convert';

import 'package:flutterhole/model/serializable.dart';
import 'package:meta/meta.dart';

/// The API model for http://pi.hole/admin/api.php?status.
class Status extends Serializable {
  final bool enabled;

  bool get disabled => !enabled;

  Status({
    @required this.enabled,
  }) : super([enabled]);

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
