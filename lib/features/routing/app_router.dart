import 'package:auto_route/auto_route.dart';
import 'package:flutterhole_web/features/about/about_page.dart';
import 'package:flutterhole_web/features/query_log/query_log_page.dart';
import 'package:flutterhole_web/features/settings/better_settings.dart';
import 'package:flutterhole_web/features/settings/dashboard_settings_page.dart';
import 'package:flutterhole_web/features/settings/pi_edit_page.dart';
import 'package:flutterhole_web/features/settings/single_pi_page.dart';
import 'package:flutterhole_web/home_page.dart';
import 'package:flutterhole_web/settings_page.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(page: HomePage, initial: true),
    AutoRoute(page: QueryLogPage),
    AutoRoute(page: SettingsPage),
    AutoRoute(page: BetterSettingsPage),
    AutoRoute(page: DashboardSettingsPage),
    AutoRoute(page: PiEditPage),
    AutoRoute(page: SinglePiPage),
    AutoRoute(page: AboutPage),
  ],
)
class $AppRouter {}
