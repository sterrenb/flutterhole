import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/features/logging/loggers.dart';
import 'package:flutterhole_web/features/routing/app_router.gr.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:flutterhole_web/features/settings/settings_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:refreshables/refreshables.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();

  runApp(ProviderScope(
    observers: kDebugMode
        ? <ProviderObserver>[
            ProviderLogger(),
          ]
        : [],
    overrides: [
      settingsRepositoryProvider
          .overrideWithValue(SettingsRepository(preferences))
    ],
    child: const MyApp(),
  ));

  runApp(ProviderScope(
    child: DevicePreview(
      enabled: false,
      // enabled: !kReleaseMode,
      builder: (context) => const MyApp(),
    ),
  ));
}

class MyApp extends HookWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeMode = useProvider(themeModeProvider);
    final router = useState(AppRouter()).value;
    return RefreshableWaterDropConfiguration(
      child: MaterialApp.router(
        title: 'FlutterHole',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.orange,
          accentColor: Colors.orangeAccent,
          // scaffoldBackgroundColor: Color(0xFFFAFBFC),
          scaffoldBackgroundColor: const Color(0xFFECF0F5),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.orange,
          accentColor: Colors.orangeAccent,
          toggleableActiveColor: Colors.orangeAccent,
          // colorScheme: ColorScheme.dark(
          //   secondary: Colors.orangeAccent,
          // ),
          scaffoldBackgroundColor: const Color(0xFF121212),
          // canvasColor: Color(0xFF121212),
          cardColor: const Color(0xFF1E1E1E),
          dialogBackgroundColor: const Color(0xFF1E1E1E),
        ),
        themeMode: themeMode,
        routerDelegate: router.delegate(),
        routeInformationParser: router.defaultRouteParser(),
        locale: const Locale('en', 'us'),
        builder: DevicePreview.appBuilder,
        // locale: Localizations.localeOf(context),
      ),
    );
  }
}
