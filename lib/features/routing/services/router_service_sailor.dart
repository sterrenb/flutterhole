import 'package:alice/alice.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/navigator.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/home/presentation/pages/home_page.dart';
import 'package:flutterhole/features/pihole_api/blocs/list_bloc.dart';
import 'package:flutterhole/features/pihole_api/presentation/pages/blacklist_page.dart';
import 'package:flutterhole/features/pihole_api/presentation/pages/query_log_page.dart';
import 'package:flutterhole/features/pihole_api/presentation/pages/whitelist_page.dart';
import 'package:flutterhole/features/routing/presentation/pages/about_page.dart';
import 'package:flutterhole/features/routing/services/router_service.dart';
import 'package:flutterhole/features/settings/presentation/pages/all_pihole_settings_page.dart';
import 'package:flutterhole/features/settings/presentation/pages/settings_page.dart';
import 'package:flutterhole/features/settings/presentation/pages/user_preferences_page.dart';
import 'package:injectable/injectable.dart';
import 'package:sailor/sailor.dart';

@Singleton(as: RouterService)
class RouterServiceSailor implements RouterService {
  RouterServiceSailor([Sailor sailor, Alice alice])
      : _sailor = sailor ?? getIt<Sailor>(),
        _alice = alice ?? getIt<Alice>() {
    _alice.setNavigatorKey(navigatorKey);
  }

  final Sailor _sailor;
  final Alice _alice;

  @override
  void createRoutes() {
    _sailor.addRoutes([
      SailorRoute(
          name: RouterService.home,
          builder: (context, args, params) {
            return HomePage();
          }),
      SailorRoute(
          name: RouterService.queryLog,
          builder: (context, args, params) {
            return QueryLogPage();
          }),
      SailorRoute(
          name: RouterService.whitelist,
          builder: (context, args, params) {
            getIt<ListBloc>().add(ListBlocEvent.fetchLists());
            return WhitelistPage();
          }),
      SailorRoute(
          name: RouterService.blacklist,
          builder: (context, args, params) {
            getIt<ListBloc>().add(ListBlocEvent.fetchLists());
            return BlacklistPage();
          }),
      SailorRoute(
          name: RouterService.settings,
          builder: (context, args, params) {
            return SettingsPage();
          }),
      SailorRoute(
          name: RouterService.allPiholes,
          builder: (context, args, params) {
            return AllPiholeSettingsPage();
          }),
      SailorRoute(
          name: RouterService.userPreferences,
          builder: (context, args, params) {
            return UserPreferencesPage();
          }),
      SailorRoute(
          name: RouterService.about,
          builder: (context, args, params) {
            return AboutPage();
          }),
    ]);
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => _sailor.navigatorKey;

  @override
  RouteFactory get onGenerateRoute => _sailor.generator();

  @override
  Future<T> push<T>(String routeName) => _sailor.navigate(routeName);

  @override
  Future<T> pushFromRoot<T>(String routeName) => _sailor.navigate(
        routeName,
        navigationType: NavigationType.pushAndRemoveUntil,
        removeUntilPredicate: (_) => false,
      );
}
