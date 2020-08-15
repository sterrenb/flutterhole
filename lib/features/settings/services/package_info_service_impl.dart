import 'package:flutterhole/features/settings/services/package_info_service.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info/package_info.dart';

@Environment(Environment.prod)
@Environment(Environment.dev)
@Singleton(as: PackageInfoService)
class PackageInfoServiceImpl implements PackageInfoService {
  PackageInfoServiceImpl._(this._info);

  @factoryMethod
  static Future<PackageInfoServiceImpl> create() async =>
      PackageInfoServiceImpl._(await PackageInfo.fromPlatform());

  final PackageInfo _info;

  @override
  PackageInfo get packageInfo => _info;
}
