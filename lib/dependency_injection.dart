import 'package:dio/dio.dart';
import 'package:flutterhole/dependency_injection.iconfig.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

final getIt = GetIt.instance;

@injectableInit
Future<void> configure(String environment) async {
  await $initGetIt(getIt, environment: environment);
}

@registerModule
abstract class RegisterModule {
  @prod
  @injectable
  Dio get dio => Dio();

  @prod
  @preResolve
  Future<HiveInterface> get hive async {
    await Hive.initFlutter();
//    await Hive.openBox(Constants.piholeSettingsSubDirectory);
    return Hive;
  }
}

//@test
//@injectable
//@RegisterAs(Dio)
//class MockDio extends Mock implements Dio {}
