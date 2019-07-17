import 'package:fimber/fimber.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole_again/model/blacklist.dart';
import 'package:flutterhole_again/model/pihole.dart';
import 'package:flutterhole_again/service/globals.dart';
import 'package:flutterhole_again/widget/layout/scaffold.dart';
import 'package:flutterhole_again/widget/screen/about_screen.dart';
import 'package:flutterhole_again/widget/screen/blacklist_screen.dart';
import 'package:flutterhole_again/widget/screen/pihole_screen.dart';
import 'package:flutterhole_again/widget/screen/privacy_screen.dart';
import 'package:flutterhole_again/widget/screen/query_log_screen.dart';
import 'package:flutterhole_again/widget/screen/settings_screen.dart';
import 'package:flutterhole_again/widget/screen/summary_screen.dart';
import 'package:flutterhole_again/widget/screen/whitelist_screen.dart';

final FimberLog _logger = FimberLog('Routes');

/// Provides access to the String version of all routes.
/// The route to [SummaryScreen].
const String rootPath = '/';

/// The route to [QueryLogScreen].
const String queryPath = '/query';

/// The route to [AboutScreen].
const String aboutPath = '/about';

/// The route to [PrivacyScreen].
const String privacyPath = '$aboutPath/privacy';

/// The route to [SettingsScreen].
const String settingsPath = '/settings';

/// The abstract route to [PiholeEditScreen].
const String _piholeEditPath = '/settings/:key';

/// The concrete route to [PiholeEditScreen] with [pihole].
String piholeEditPath(Pihole pihole) =>
    _piholeEditPath.replaceAll(':key', pihole.localKey);

/// The route to [WhitelistViewScreen].
const String whitelistPath = '/whitelist';

/// The route to [WhitelistAddScreen].
const String whitelistAddPath = '/whitelist/add';

/// The abstract route to [WhitelistEditScreen].
const String _whitelistEditPath = '/whitelist/edit/:domain';

/// The concrete route to [WhitelistEditScreen] with [domain].
String whitelistEditPath(String domain) =>
    _whitelistEditPath.replaceAll(':domain', domain);

/// The route to [BlacklistViewScreen].
const String blacklistPath = '/blacklist';

/// The route to [BlacklistAddScreen].
const String blacklistAddPath = '/blacklist/add';

/// The abstract route to [BlacklistEditScreen].
const String _blacklistEditPath = '/blacklist/edit/:entry/:listType';

/// The concrete route to [BlacklistEditScreen] with [item].
String blacklistEditPath(BlacklistItem item) =>
    _blacklistEditPath
        .replaceAll(':entry', item.entry)
        .replaceAll(':listType', item.listKey);

/// A [Handler] with a [handlerFunc] that takes no parameters and returns [child] on route push.
class _SimpleHandler extends Handler {
  _SimpleHandler(Widget child) : super(handlerFunc: (_, __) => child);
}

/// Signature for [Handler.handlerFunc] without [BuildContext].
typedef ParamsCallBack = Widget Function(Map<String, List<String>> params);

/// A [Handler] with a [handlerFunc] that takes [params] and returns [ParamsCallBack] on route push.
class _ParamsHandler extends Handler {
  _ParamsHandler(ParamsCallBack callback)
      : super(
      handlerFunc: (_, Map<String, List<String>> params) =>
          callback(params));
}

/// Configures all application routes for [router].
///
/// Logs an error if a route is not found.
void configureRoutes(Router router) {
  router.notFoundHandler = _ParamsHandler((params) {
    _logger.e('route not found: $params');
    return SimpleScaffold(
      titleString: 'Oops',
      body: Center(child: Text('Route not found: $params')),
    );
  });

  router.define(rootPath, handler: _SimpleHandler(SummaryScreen()));

  router.define(queryPath, handler: _SimpleHandler(QueryLogScreen()));

  router.define(whitelistPath, handler: _SimpleHandler(WhitelistViewScreen()));

  router.define(whitelistAddPath,
      handler: _SimpleHandler(WhitelistAddScreen()));

  router.define(_whitelistEditPath,
      handler: _ParamsHandler(
              (params) => WhitelistEditScreen(original: params['domain'][0])));

  router.define(blacklistPath, handler: _SimpleHandler(BlacklistViewScreen()));

  router.define(blacklistAddPath,
      handler: _SimpleHandler(BlacklistAddScreen()));

  router.define(_blacklistEditPath,
      handler: _ParamsHandler((params) =>
          BlacklistEditScreen(
            original: BlacklistItem(
              entry: params['entry'][0],
              type: blacklistTypeFromString(params['listType'][0]),
            ),
          )));

  router.define(settingsPath, handler: _SimpleHandler(SettingsScreen()));

  router.define(_piholeEditPath,
      handler: _ParamsHandler((params) =>
          PiholeEditScreen(
              pihole: Globals.localStorage.cache[params['key'][0]])));

  router.define(aboutPath, handler: _SimpleHandler(AboutScreen()));

  router.define(privacyPath, handler: _SimpleHandler(PrivacyScreen()));
}
