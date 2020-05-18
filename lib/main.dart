import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutterhole/core/debug/bloc_delegate.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/pihole_api/blocs/pi_connection_bloc.dart';
import 'package:flutterhole/features/routing/services/router_service.dart';
import 'package:flutterhole/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:flutterhole/features/settings/presentation/notifiers/theme_mode_notifier.dart';
import 'package:injectable/injectable.dart';
import 'package:provider/provider.dart';

void main([List<String> arguments = const [Environment.prod]]) async {
  // wait for flutter initialization
  WidgetsFlutterBinding.ensureInitialized();

  print('args: $arguments');

  // Configure service injection
  List<String> args = List.from(arguments) ?? [];
  if (args.isEmpty) args.add(Environment.prod);
  await configure(args.first);

  if (foundation.kReleaseMode) {
  } else {
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
    return ChangeNotifierProvider<ThemeModeNotifier>(
      create: (_) => ThemeModeNotifier(),
      child: Consumer<ThemeModeNotifier>(
        builder: (BuildContext context,
            ThemeModeNotifier notifier,
            _,) {
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
            themeMode: notifier.themeMode,
          );
        },
      ),
    );
  }
}
