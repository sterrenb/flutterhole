import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutterhole/core/debug/bloc_delegate.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/pihole_api/blocs/pi_connection_bloc.dart';
import 'package:flutterhole/features/routing/services/router_service.dart';
import 'package:flutterhole/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:injectable/injectable.dart';

void main() async {
  // wait for flutter initialization
  WidgetsFlutterBinding.ensureInitialized();

  // Configure service injection
  await configure(Environment.prod);

  if (foundation.kReleaseMode) {} else {
    enableBlocDelegate();
  }

  getIt<RouterService>().createRoutes();
  getIt<SettingsBloc>().add(SettingsEvent.init());
  getIt<PiConnectionBloc>().add(PiConnectionEvent.ping());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterHole',
      navigatorKey: getIt<RouterService>().navigatorKey,
      onGenerateRoute: getIt<RouterService>().onGenerateRoute,
      initialRoute: RouterService.home,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
