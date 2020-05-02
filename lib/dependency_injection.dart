import 'package:dio/dio.dart';
import 'package:flutterhole/constants.dart';
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
  @injectable
  Dio get dio => Dio();

  @prod
  @preResolve
  Future<HiveInterface> get hive async {
    print('preresolving hive');
    await Hive.initFlutter(Constants.settingsSubDirectory);
//    await Hive.openBox(Constants.piholeSettingsSubDirectory);
    return Hive;
  }
}

//@test
//@injectable
//@RegisterAs(Dio)
//class MockDio extends Mock implements Dio {}
