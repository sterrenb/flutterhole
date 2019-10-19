import 'dart:convert';

import 'package:flutterhole/model/serializable.dart';

class Versions extends Serializable {
  Versions({
    this.coreUpdate,
    this.webUpdate,
    this.ftlUpdate,
    this.coreCurrent,
    this.webCurrent,
    this.ftlCurrent,
    this.coreLatest,
    this.webLatest,
    this.ftlLatest,
    this.coreBranch,
    this.webBranch,
    this.ftlBranch,
  });

  final bool coreUpdate;
  final bool webUpdate;
  final bool ftlUpdate;
  final String coreCurrent;
  final String webCurrent;
  final String ftlCurrent;
  final String coreLatest;
  final String webLatest;
  final String ftlLatest;
  final String coreBranch;
  final String webBranch;
  final String ftlBranch;

  @override
  List<Object> get props =>
      [
        coreUpdate,
        webUpdate,
        ftlUpdate,
        coreCurrent,
        webCurrent,
        ftlCurrent,
        coreLatest,
        webLatest,
        ftlLatest,
        coreBranch,
        webBranch,
        ftlBranch,
      ];

  factory Versions.fromString(String str) =>
      Versions.fromJson(json.decode(str));

  factory Versions.fromJson(Map<String, dynamic> json) =>
      Versions(
        coreUpdate: json["core_update"],
        webUpdate: json["web_update"],
        ftlUpdate: json["FTL_update"],
        coreCurrent: json["core_current"],
        webCurrent: json["web_current"],
        ftlCurrent: json["FTL_current"],
        coreLatest: json["core_latest"],
        webLatest: json["web_latest"],
        ftlLatest: json["FTL_latest"],
        coreBranch: json["core_branch"],
        webBranch: json["web_branch"],
        ftlBranch: json["FTL_branch"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "core_update": coreUpdate,
        "web_update": webUpdate,
        "FTL_update": ftlUpdate,
        "core_current": coreCurrent,
        "web_current": webCurrent,
        "FTL_current": ftlCurrent,
        "core_latest": coreLatest,
        "web_latest": webLatest,
        "FTL_latest": ftlLatest,
        "core_branch": coreBranch,
        "web_branch": webBranch,
        "FTL_branch": ftlBranch,
      };
}
