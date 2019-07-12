import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole_again/screen/about_screen.dart';
import 'package:flutterhole_again/screen/settings_screen.dart';
import 'package:flutterhole_again/screen/summary_screen.dart';
import 'package:flutterhole_again/screen/whitelist_add_screen.dart';
import 'package:flutterhole_again/screen/whitelist_view_screen.dart';

const String rootPath = '/';
const String summaryPath = '/summary';
const String settingsPath = '/settings';
const String aboutPath = '/about';

const String whitelistPath = '/whitelist';
const String whitelistAddPath = '/whitelist/add';
const String _whitelistEdit = '/whitelist/edit/:domain';

String whitelistEditPath(String domain) =>
    _whitelistEdit.replaceAll(':domain', domain);

void configureRoutes(Router router) {
  router.notFoundHandler = Handler(handlerFunc: (_, __) {
    print('route not found');
    return Container();
  });

  router.define(rootPath,
      handler: Handler(handlerFunc: (_, __) => SummaryScreen()));

  router.define(summaryPath,
      handler: Handler(handlerFunc: (_, __) => SummaryScreen()));

  router.define(whitelistPath,
      handler: Handler(handlerFunc: (_, __) => WhitelistViewScreen()));

  router.define(whitelistAddPath,
      handler: Handler(handlerFunc: (_, __) => WhitelistAddScreen()));

  router.define(settingsPath,
      handler: Handler(handlerFunc: (_, __) => SettingsScreen()));

  router.define(aboutPath,
      handler: Handler(handlerFunc: (_, __) => AboutScreen()));
}
