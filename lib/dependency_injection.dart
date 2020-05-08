import 'package:alice/alice.dart';
import 'package:dio/dio.dart';
import 'package:flutterhole/dependency_injection.iconfig.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:sailor/sailor.dart';

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
  @singleton
  Future<HiveInterface> get hive async {
    await Hive.initFlutter();
    return Hive;
  }

  @prod
  @singleton
  Sailor get sailor => Sailor(
          options: SailorOptions(
        isLoggingEnabled: true,
      ));

  @singleton
  Alice get alice => Alice(
        showNotification: false,
        darkTheme: true,
      );
}
