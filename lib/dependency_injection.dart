import 'package:alice/alice.dart';
import 'package:dio/dio.dart';
import 'package:flutterhole/dependency_injection.config.dart';
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

@module
abstract class RegisterProdModule {
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
        isLoggingEnabled: false,
      ));

  @prod
  @singleton
  Alice get alice => Alice(
        showNotification: false,
        darkTheme: true,
      );
}
