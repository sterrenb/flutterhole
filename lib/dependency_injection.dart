import 'package:dio/dio.dart';
import 'package:flutterhole/dependency_injection.iconfig.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final getIt = GetIt.instance;

@injectableInit
Future<void> configure(String environment) async {
  $initGetIt(getIt, environment: environment);
}

@registerModule
abstract class RegisterModule {
  @injectable
  Dio get dio => Dio();
}

//@test
//@injectable
//@RegisterAs(Dio)
//class MockDio extends Mock implements Dio {}
