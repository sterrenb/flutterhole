import 'package:auto_route/auto_route.dart';
import 'package:flutterhole_web/features/about/about_page.dart';
import 'package:flutterhole_web/features/about/privacy_page.dart';
import 'package:flutterhole_web/features/logging/logs_page.dart';
import 'package:flutterhole_web/features/onboarding/onboarding_page.dart';
import 'package:flutterhole_web/features/query_log/better_query_log_page.dart';
import 'package:flutterhole_web/features/settings/dashboard_settings_page.dart';
import 'package:flutterhole_web/features/settings/my_pi_holes_page.dart';
import 'package:flutterhole_web/features/settings/settings_page.dart';
import 'package:flutterhole_web/features/settings/single_pi_page.dart';
import 'package:flutterhole_web/home_page.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(page: OnboardingPage),
    AutoRoute(page: HomePage, initial: true),
    AutoRoute(page: BetterQueryLogPage),
    AutoRoute(page: SettingsPage),
    AutoRoute(page: LogsPage, fullscreenDialog: true),
    AutoRoute(page: DashboardSettingsPage),
    AutoRoute(page: MyPiHolesPage),
    AutoRoute(page: SinglePiPage),
    AutoRoute(page: AboutPage),
    AutoRoute(page: PrivacyPage, fullscreenDialog: true),
  ],
)
class $AppRouter {}
