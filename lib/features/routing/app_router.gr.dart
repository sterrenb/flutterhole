// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:auto_route/auto_route.dart' as _i1;
import 'package:flutter/material.dart' as _i2;

import '../../home_page.dart' as _i3;
import '../about/about_page.dart' as _i10;
import '../about/privacy_page.dart' as _i11;
import '../entities/settings_entities.dart' as _i12;
import '../logging/logs_page.dart' as _i6;
import '../query_log/query_log_page.dart' as _i4;
import '../settings/dashboard_settings_page.dart' as _i7;
import '../settings/my_pi_holes_page.dart' as _i8;
import '../settings/settings_page.dart' as _i5;
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
          return const _i5.SettingsPage();
        }),
    LogsRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return const _i6.LogsPage();
        },
        fullscreenDialog: true),
    DashboardSettingsRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (data) {
          final args = data.argsAs<DashboardSettingsRouteArgs>();
          return _i7.DashboardSettingsPage(
              key: args.key, initial: args.initial, onSave: args.onSave);
        }),
    MyPiHolesRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return const _i8.MyPiHolesPage();
        }),
    SinglePiRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (data) {
          final args = data.argsAs<SinglePiRouteArgs>();
          return _i9.SinglePiPage(
              initial: args.initial,
              onSave: args.onSave,
              title: args.title,
              key: args.key);
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
        _i1.RouteConfig(LogsRoute.name, path: '/logs-page'),
        _i1.RouteConfig(DashboardSettingsRoute.name,
            path: '/dashboard-settings-page'),
        _i1.RouteConfig(MyPiHolesRoute.name, path: '/my-pi-holes-page'),
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

class LogsRoute extends _i1.PageRouteInfo {
  const LogsRoute() : super(name, path: '/logs-page');

  static const String name = 'LogsRoute';
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

class MyPiHolesRoute extends _i1.PageRouteInfo {
  const MyPiHolesRoute() : super(name, path: '/my-pi-holes-page');

  static const String name = 'MyPiHolesRoute';
}

class SinglePiRoute extends _i1.PageRouteInfo<SinglePiRouteArgs> {
  SinglePiRoute(
      {required _i12.Pi initial,
      required void Function(_i12.Pi) onSave,
      String? title,
      _i2.Key? key})
      : super(name,
            path: '/single-pi-page',
            args: SinglePiRouteArgs(
                initial: initial, onSave: onSave, title: title, key: key));

  static const String name = 'SinglePiRoute';
}

class SinglePiRouteArgs {
  const SinglePiRouteArgs(
      {required this.initial, required this.onSave, this.title, this.key});

  final _i12.Pi initial;

  final void Function(_i12.Pi) onSave;

  final String? title;

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
