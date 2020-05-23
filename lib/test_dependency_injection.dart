import 'package:alice/alice.dart';
import 'package:dio/dio.dart';
import 'package:flutterhole/features/pihole_api/data/datasources/api_data_source.dart';
import 'package:flutterhole/features/settings/services/package_info_service.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:mockito/mockito.dart';
import 'package:sailor/sailor.dart';

@Environment(Environment.test)
@injectable
@RegisterAs(ApiDataSource)
class MockApiDataSource extends Mock implements ApiDataSource {}

@Environment(Environment.test)
@injectable
@RegisterAs(PackageInfoService)
class MockPackageInfoService extends Mock implements PackageInfoService {}

class MockHive extends Mock implements HiveInterface {}

@registerModule
abstract class RegisterTestModule {
  @test
  @injectable
  Dio get dio => Dio();

  @test
  @singleton
  HiveInterface get hive => MockHive();

  @test
  @singleton
  Sailor get sailor => Sailor(
          options: SailorOptions(
        isLoggingEnabled: true,
      ));

  @test
  @singleton
  Alice get alice => Alice(
        showNotification: false,
        darkTheme: true,
      );
}
