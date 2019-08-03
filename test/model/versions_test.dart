import 'package:flutterhole/model/api/versions.dart';
import "package:test/test.dart";

import '../mock.dart';

void main() {
  Versions versions;
  Map<String, dynamic> map;

  setUp(() {
    map = {
      "core_update": mockVersions.coreUpdate,
      "web_update": mockVersions.webUpdate,
      "FTL_update": mockVersions.ftlUpdate,
      "core_current": mockVersions.coreCurrent,
      "web_current": mockVersions.webCurrent,
      "FTL_current": mockVersions.ftlCurrent,
      "core_latest": mockVersions.coreLatest,
      "web_latest": mockVersions.webLatest,
      "FTL_latest": mockVersions.ftlLatest,
      "core_branch": mockVersions.coreBranch,
      "web_branch": mockVersions.webBranch,
      "FTL_branch": mockVersions.ftlBranch,
    };
  });

  test('constructor', () {
    versions = Versions();

    expect(versions.coreUpdate, isNull);
    expect(versions.webUpdate, isNull);
    expect(versions.ftlUpdate, isNull);
    expect(versions.coreCurrent, isNull);
    expect(versions.webCurrent, isNull);
    expect(versions.ftlCurrent, isNull);
    expect(versions.coreLatest, isNull);
    expect(versions.webLatest, isNull);
    expect(versions.ftlLatest, isNull);
    expect(versions.coreBranch, isNull);
    expect(versions.webBranch, isNull);
    expect(versions.ftlBranch, isNull);
  });

  test('fromString', () {
    expect(
        Versions.fromString(
            '{"core_update":true,"web_update":false,"FTL_update":false,"core_current":"v1.2.3","web_current":"v1.2.4","FTL_current":"v1.2.5","core_latest":"","web_latest":"","FTL_latest":"","core_branch":"master","web_branch":"master","FTL_branch":"master"}'),
        mockVersions);
  });

  test('toJson', () {
    expect(mockVersions.toJson(), map);
  });

  test('fromJson', () {
    expect(Versions.fromJson(map), mockVersions);
  });
}
