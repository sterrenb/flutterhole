import 'package:fimber/fimber.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole_again/model/blacklist.dart';
import 'package:flutterhole_again/model/pihole.dart';
import 'package:flutterhole_again/service/globals.dart';
import 'package:flutterhole_again/widget/screen/about_screen.dart';
import 'package:flutterhole_again/widget/screen/blacklist/blacklist_add_screen.dart';
import 'package:flutterhole_again/widget/screen/blacklist/blacklist_edit_screen.dart';
import 'package:flutterhole_again/widget/screen/blacklist/blacklist_view_screen.dart';
import 'package:flutterhole_again/widget/screen/pihole/pihole_edit_screen.dart';
import 'package:flutterhole_again/widget/screen/privacy_screen.dart';
import 'package:flutterhole_again/widget/screen/query_log_screen.dart';
import 'package:flutterhole_again/widget/screen/settings_screen.dart';
import 'package:flutterhole_again/widget/screen/summary_screen.dart';
import 'package:flutterhole_again/widget/screen/whitelist/whitelist_add_screen.dart';
import 'package:flutterhole_again/widget/screen/whitelist/whitelist_edit_screen.dart';
import 'package:flutterhole_again/widget/screen/whitelist/whitelist_view_screen.dart';

const String rootPath = '/';
const String summaryPath = '/summary';
const String queryPath = '/query';
const String aboutPath = '/about';
const String privacyPath = '$aboutPath/privacy';

const String settingsPath = '/settings';
const String _piholeEditPath = '/settings/:key';

class Route {}

String piholeEditPath(Pihole pihole) =>
    _piholeEditPath.replaceAll(':key', pihole.localKey);

const String whitelistPath = '/whitelist';
const String whitelistAddPath = '/whitelist/add';
const String _whitelistEditPath = '/whitelist/edit/:domain';

String whitelistEditPath(String domain) =>
    _whitelistEditPath.replaceAll(':domain', domain);

const String blacklistPath = '/blacklist';
const String blacklistAddPath = '/blacklist/add';
const String _blacklistEditPath = '/blacklist/edit/:entry/:listType';

String blacklistEditPath(BlacklistItem item) =>
    _blacklistEditPath
        .replaceAll(':entry', item.entry)
        .replaceAll(':listType', item.listKey);

void configureRoutes(Router router) {
  router.notFoundHandler =
      Handler(handlerFunc: (_, Map<String, List<String>> params) {
        Fimber.e('route not found: $params');
        return Container();
      });

  router.define(rootPath,
      handler: Handler(handlerFunc: (_, __) => SummaryScreen()));

  router.define(summaryPath,
      handler: Handler(handlerFunc: (_, __) => SummaryScreen()));

  router.define(queryPath,
      handler: Handler(handlerFunc: (_, __) => QueryLogScreen()));

  router.define(whitelistPath,
      handler: Handler(handlerFunc: (_, __) => WhitelistViewScreen()));

  router.define(whitelistAddPath,
      handler: Handler(handlerFunc: (_, __) => WhitelistAddScreen()));

  router.define(_whitelistEditPath,
      handler: Handler(
          handlerFunc:
              (BuildContext context, Map<String, List<String>> params) =>
              WhitelistEditScreen(original: params['domain'][0])));

  router.define(blacklistPath,
      handler: Handler(handlerFunc: (_, __) => BlacklistViewScreen()));

  router.define(blacklistAddPath,
      handler: Handler(handlerFunc: (_, __) => BlacklistAddScreen()));

  router.define(_blacklistEditPath,
      handler: Handler(
          handlerFunc:
              (BuildContext context, Map<String, List<String>> params) =>
              BlacklistEditScreen(
                original: BlacklistItem(
                  entry: params['entry'][0],
                  type: blacklistTypeFromString(params['listType'][0]),
                ),
              )));

  router.define(settingsPath,
      handler: Handler(handlerFunc: (_, __) => SettingsScreen()));

  router.define(_piholeEditPath,
      handler: Handler(
          handlerFunc:
              (BuildContext context, Map<String, List<String>> params) =>
              PiholeEditScreen(
                  pihole: Globals.localStorage.cache[params['key'][0]])));

  router.define(aboutPath,
      handler: Handler(handlerFunc: (_, __) => AboutScreen()));

  router.define(privacyPath,
      handler: Handler(handlerFunc: (_, __) => PrivacyScreen()));
}
