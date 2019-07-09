import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole_again/screen/about_screen.dart';
import 'package:flutterhole_again/screen/settings_screen.dart';
import 'package:flutterhole_again/screen/summary_screen.dart';

const String rootPath = '/';
const String summaryPath = '/summary';
const String settingsPath = '/settings';
const String aboutPath = '/about';

void configureRoutes(Router router) {
  router.notFoundHandler = Handler(handlerFunc: (_, __) {
    print('route not found');
    return Container();
  });

  router.define(rootPath,
      handler: Handler(handlerFunc: (_, __) => SummaryScreen()));

  router.define(summaryPath,
      handler: Handler(handlerFunc: (_, __) => SummaryScreen()));

  router.define(settingsPath,
      handler: Handler(handlerFunc: (_, __) => SettingsScreen()));

  router.define(aboutPath,
      handler: Handler(handlerFunc: (_, __) => AboutScreen()));
}
