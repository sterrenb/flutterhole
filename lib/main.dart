import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/routing/app_router.gr.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:flutterhole_web/features/settings/settings_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Logger extends ProviderObserver {
  @override
  void didUpdateProvider(ProviderBase provider, Object? newValue) {
    print('''

  "{ provider": "${provider.name ?? provider.runtimeType}",
  "  newValue": ${newValue.toString()} }
''');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();

  runApp(ProviderScope(
    observers: <ProviderObserver>[
      // Logger(),
    ],
    overrides: [
      settingsRepositoryProvider
          .overrideWithValue(SettingsRepository(preferences))
    ],
    child: MyApp(),
  ));
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends HookWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeMode = useProvider(themeModeProvider);
    final router = useState(AppRouter()).value;
    return RefreshConfiguration(
      headerBuilder: () => WaterDropMaterialHeader(),
      child: MaterialApp.router(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: Color(0xFFFAFBFC),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          accentColor: Colors.orangeAccent,
          toggleableActiveColor: Colors.orangeAccent,
          colorScheme: ColorScheme.dark(
            secondary: Colors.orangeAccent,
          ),
          scaffoldBackgroundColor: Color(0xFF121212),
          // canvasColor: Color(0xFF121212),
          cardColor: KColors.versions,
          dialogBackgroundColor: KColors.versions,
        ),
        themeMode: themeMode,
        routerDelegate: router.delegate(),
        routeInformationParser: router.defaultRouteParser(),
        // home: const HomeScreen(),
        // home: const DashboardPage(),
        // home: const QueryLogScreen(),
      ),
    );
  }
}
