// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:auto_route/auto_route.dart' as _i1;
import 'package:flutter/material.dart' as _i2;

import '../../entities.dart' as _i12;
import '../../home_page.dart' as _i3;
import '../../settings_page.dart' as _i5;
import '../about/about_page.dart' as _i10;
import '../about/privacy_page.dart' as _i11;
import '../query_log/query_log_page.dart' as _i4;
import '../settings/better_settings.dart' as _i6;
import '../settings/dashboard_settings_page.dart' as _i7;
import '../settings/pi_edit_page.dart' as _i8;
import '../settings/single_pi_page.dart' as _i9;

class AppRouter extends _i1.RootStackRouter {
  AppRouter([_i2.GlobalKey<_i2.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i1.PageFactory> pagesMap = {
    HomeRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return const _i3.HomePage();
        }),
    QueryLogRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return const _i4.QueryLogPage();
        }),
    SettingsRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i5.SettingsPage();
        }),
    BetterSettingsRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return const _i6.BetterSettingsPage();
        }),
    DashboardSettingsRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (data) {
          final args = data.argsAs<DashboardSettingsRouteArgs>();
          return _i7.DashboardSettingsPage(
              key: args.key, initial: args.initial, onSave: args.onSave);
        }),
    PiEditRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return const _i8.PiEditPage();
        }),
    SinglePiRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (data) {
          final args = data.argsAs<SinglePiRouteArgs>();
          return _i9.SinglePiPage(
              initial: args.initial, onSave: args.onSave, key: args.key);
        }),
    AboutRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return const _i10.AboutPage();
        }),
    PrivacyRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return const _i11.PrivacyPage();
        })
  };

  @override
  List<_i1.RouteConfig> get routes => [
        _i1.RouteConfig(HomeRoute.name, path: '/'),
        _i1.RouteConfig(QueryLogRoute.name, path: '/query-log-page'),
        _i1.RouteConfig(SettingsRoute.name, path: '/settings-page'),
        _i1.RouteConfig(BetterSettingsRoute.name,
            path: '/better-settings-page'),
        _i1.RouteConfig(DashboardSettingsRoute.name,
            path: '/dashboard-settings-page'),
        _i1.RouteConfig(PiEditRoute.name, path: '/pi-edit-page'),
        _i1.RouteConfig(SinglePiRoute.name, path: '/single-pi-page'),
        _i1.RouteConfig(AboutRoute.name, path: '/about-page'),
        _i1.RouteConfig(PrivacyRoute.name, path: '/privacy-page')
      ];
}

class HomeRoute extends _i1.PageRouteInfo {
  const HomeRoute() : super(name, path: '/');

  static const String name = 'HomeRoute';
}

class QueryLogRoute extends _i1.PageRouteInfo {
  const QueryLogRoute() : super(name, path: '/query-log-page');

  static const String name = 'QueryLogRoute';
}

class SettingsRoute extends _i1.PageRouteInfo {
  const SettingsRoute() : super(name, path: '/settings-page');

  static const String name = 'SettingsRoute';
}

class BetterSettingsRoute extends _i1.PageRouteInfo {
  const BetterSettingsRoute() : super(name, path: '/better-settings-page');

  static const String name = 'BetterSettingsRoute';
}

class DashboardSettingsRoute
    extends _i1.PageRouteInfo<DashboardSettingsRouteArgs> {
  DashboardSettingsRoute(
      {_i2.Key? key,
      required _i12.DashboardSettings initial,
      required void Function(_i12.DashboardSettings) onSave})
      : super(name,
            path: '/dashboard-settings-page',
            args: DashboardSettingsRouteArgs(
                key: key, initial: initial, onSave: onSave));

  static const String name = 'DashboardSettingsRoute';
}

class DashboardSettingsRouteArgs {
  const DashboardSettingsRouteArgs(
      {this.key, required this.initial, required this.onSave});

  final _i2.Key? key;

  final _i12.DashboardSettings initial;

  final void Function(_i12.DashboardSettings) onSave;
}

class PiEditRoute extends _i1.PageRouteInfo {
  const PiEditRoute() : super(name, path: '/pi-edit-page');

  static const String name = 'PiEditRoute';
}

class SinglePiRoute extends _i1.PageRouteInfo<SinglePiRouteArgs> {
  SinglePiRoute(
      {required _i12.Pi initial,
      required void Function(_i12.Pi) onSave,
      _i2.Key? key})
      : super(name,
            path: '/single-pi-page',
            args:
                SinglePiRouteArgs(initial: initial, onSave: onSave, key: key));

  static const String name = 'SinglePiRoute';
}

class SinglePiRouteArgs {
  const SinglePiRouteArgs(
      {required this.initial, required this.onSave, this.key});

  final _i12.Pi initial;

  final void Function(_i12.Pi) onSave;

  final _i2.Key? key;
}

class AboutRoute extends _i1.PageRouteInfo {
  const AboutRoute() : super(name, path: '/about-page');

  static const String name = 'AboutRoute';
}

class PrivacyRoute extends _i1.PageRouteInfo {
  const PrivacyRoute() : super(name, path: '/privacy-page');

  static const String name = 'PrivacyRoute';
}
