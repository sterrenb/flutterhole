import 'package:package_info/package_info.dart';

extension PackageInfoPrintable on PackageInfo {
  String get versionAndBuildString => '$version (build #$buildNumber)';
}

abstract class PackageInfoService {
  PackageInfo get packageInfo;
}
