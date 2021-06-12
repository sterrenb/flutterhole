import 'package:auto_route/auto_route.dart';
import 'package:flutterhole_web/features/about/about_page.dart';
import 'package:flutterhole_web/features/query_log/query_log_page.dart';
import 'package:flutterhole_web/features/settings/pi_edit_page.dart';
import 'package:flutterhole_web/home_page.dart';
import 'package:flutterhole_web/settings_page.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(page: HomePage),
    AutoRoute(page: QueryLogPage),
    AutoRoute(page: SettingsPage),
    AutoRoute(page: PiEditPage, initial: true),
    AutoRoute(page: AboutPage),
  ],
)
class $AppRouter {}
