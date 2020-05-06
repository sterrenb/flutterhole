import 'package:alice/alice.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/navigator.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/routing/presentation/pages/about_page.dart';
import 'package:flutterhole/features/routing/presentation/pages/privacy_page.dart';
import 'package:flutterhole/features/routing/services/router_service.dart';
import 'package:flutterhole/features/settings/presentation/pages/settings_page.dart';
import 'package:flutterhole/widgets/pages/home_page.dart';
import 'package:injectable/injectable.dart';
import 'package:sailor/sailor.dart';

@prod
@singleton
@RegisterAs(RouterService)
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
          name: RouterService.settings,
          builder: (context, args, params) {
            return SettingsPage();
          }),
      SailorRoute(
          name: RouterService.about,
          builder: (context, args, params) {
            return AboutPage();
          }),
      SailorRoute(
          name: RouterService.privacy,
          builder: (context, args, params) {
            return PrivacyPage();
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
