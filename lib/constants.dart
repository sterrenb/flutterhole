import 'package:flutter/material.dart';
import 'package:flutterhole_web/features/entities/api_entities.dart';
import 'package:flutterhole_web/features/entities/settings_entities.dart';

// const String token = String.fromEnvironment('TOKEN');
// lol security
const String token =
    "3f4fa74468f336df5c4cf1d343d160f8948375732f82ea1a057138ae7d35055c";

const double kGridSpacing = 4.0;

final debugPis = <Pi>[
  Pi(
    id: 234,
    title: 'My hole',
    description: '',
    primaryColor: Colors.indigoAccent,
    accentColor: Colors.orange,
    dashboardSettings: DashboardSettings.initial(),
    baseUrl: '10.0.1.5',
    useSsl: false,
    apiPath: '/admin/api.php',
    apiPort: 80,
    apiToken: token,
    apiTokenRequired: true,
    allowSelfSignedCertificates: false,
    basicAuthenticationUsername: '',
    basicAuthenticationPassword: '',
    proxyUrl: '',
    proxyPort: 8080,
  ),
  Pi(
    id: 456,
    title: 'Broken',
    description: 'This won\'t work',
    primaryColor: Colors.orange,
    accentColor: Colors.blueAccent,
    dashboardSettings: DashboardSettings.initial(),
    baseUrl: 'example.com',
    useSsl: false,
    apiPath: 'admin/api.php',
    apiPort: 80,
    apiToken: '',
    apiTokenRequired: true,
    allowSelfSignedCertificates: false,
    basicAuthenticationUsername: '',
    basicAuthenticationPassword: 'null',
    proxyUrl: '',
    proxyPort: 8080,
  ),
  Pi(
    id: 789,
    title: 'With SSL on',
    description: '',
    primaryColor: Colors.greenAccent,
    accentColor: Colors.redAccent,
    dashboardSettings: DashboardSettings.initial(),
    baseUrl: '10.0.1.5',
    useSsl: true,
    apiPath: 'admin/api.php',
    apiPort: 80,
    apiToken: token,
    apiTokenRequired: true,
    allowSelfSignedCertificates: false,
    basicAuthenticationUsername: '',
    basicAuthenticationPassword: '',
    proxyUrl: '',
    proxyPort: 8080,
  ),
];

class KUrls {
  KUrls._();

  static const String privacyUrl =
      'https://raw.githubusercontent.com/sterrenburg/flutterhole/master/PRIVACY.md';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=sterrenburg.github.flutterhole';
  static const String githubHomeUrl =
      'https://github.com/sterrenburg/flutterhole/';
  static const String githubIssuesUrl =
      'https://github.com/sterrenburg/flutterhole/issues/new/choose';
  static const String logoDesignerUrl = 'https://mathijssterrenburg.com/';
  static const String payPalUrl = 'https://paypal.me/tsterrenburg';
  static const String koFiUrl = 'https://ko-fi.com/sterrenburg';
  static const String githubSponsor = 'https://github.com/sponsors/sterrenburg';

  static const String piHomeUrl = 'https://pi-hole.net/';
  static const String piUpdateUrl =
      'https://github.com/pi-hole/pi-hole/releases/latest';
  static const String webInterfaceUpdateUrl =
      'https://github.com/pi-hole/AdminLTE/releases/latest';
  static const String ftlUpdateUrl =
      'https://github.com/pi-hole/FTL/releases/latest';
}

class KIcons {
  KIcons._();

  static const IconData lightTheme = Icons.wb_sunny;
  static const IconData darkTheme = Icons.wb_cloudy;
  static const IconData systemTheme = Icons.wb_auto;

  static const IconData piholeTitle = Icons.handyman_sharp;

  static const IconData temperatureReading = Icons.device_thermostat;
  static const IconData memoryUsage = Icons.memory;
  static const IconData updateFrequency = Icons.update;
  static const IconData refresh = Icons.refresh;

  static const IconData dot = Icons.brightness_1;

  static const IconData appVersion = Icons.developer_board;
  static const IconData pihole = dot;

  static const IconData dashboard = Icons.dashboard;
  static const IconData queryLog = Icons.list;
  static const IconData settings = Icons.settings;
  static const IconData about = Icons.favorite;
  static const IconData info = Icons.favorite;
  static const IconData github = Icons.favorite;
  static const IconData review = Icons.star;

  static const IconData totalQueries = Icons.public;
  static const IconData queriesBlocked = Icons.block;
  static const IconData percentBlocked = Icons.pie_chart;
  static const IconData domainsOnBlocklist = Icons.list;
  static const IconData domainsPermittedTile = Icons.domain;
  static const IconData domainsBlockedTile = Icons.domain_disabled;
  static const IconData queriesOverTime = Icons.stacked_line_chart;
  static const IconData clientActivity = Icons.stacked_bar_chart;
  static const IconData debugLogs = Icons.bug_report;

  static const IconData enablePihole = Icons.play_arrow;
  static const IconData disablePihole = Icons.pause;
  static const IconData sleepPihole = Icons.alarm;
  static const IconData wakePihole = Icons.alarm_on;

  static const IconData toggleVisible = Icons.visibility;
  static const IconData toggleInvisible = Icons.visibility_off;
  static const IconData add = Icons.add;
  static const IconData save = Icons.save;

  static const IconData expand = Icons.keyboard_arrow_down;
  static const IconData shrink = Icons.keyboard_arrow_up;
  static const IconData push = Icons.keyboard_arrow_right;
  static const IconData openUrl = Icons.open_in_browser;
  static const IconData share = Icons.share;
  static const IconData donate = Icons.monetization_on;

  static const IconData selectDashboardTiles = Icons.playlist_add_check;

  static const IconData dangerZone = Icons.warning;
  static const IconData delete = Icons.delete;
  static const IconData selected = Icons.check;
  static const IconData host = Icons.dns;
  static const IconData authentication = Icons.vpn_key;
  static const IconData qrCode = Icons.qr_code_scanner;
  static const IconData customization = Icons.format_paint;
  static const IconData privacy = Icons.security;
  static const IconData bugReport = Icons.bug_report;

  static const IconData logDebug = Icons.bug_report;
  static const IconData logInfo = Icons.info;
  static const IconData logWarning = Icons.warning;
  static const IconData logError = Icons.error;
  static const IconData unknown = Icons.device_unknown;
}

class KColors {
  KColors._();

  static const Color inactive = Colors.grey;
  static const Color loading = Colors.blue;
  static const Color sleeping = Colors.blue;
  static const Color piSummary = Colors.green;
  static const Color clients = Colors.blue;
  static const Color domains = Colors.orange;
  static const Color settings = Colors.red;
  static const Color memoryUsage = Colors.blueGrey;
  static const Color versions = Color(0xFF1E1E1E);

  static const Color queryStatus = Colors.brown;
  static const Color dnsSec = Colors.blueGrey;
  static const Color timestamp = Colors.amber;
  static const Color link = Colors.blue;

  // static const Color temperatureLow = Color(0xFF005C32);
  // static const Color temperatureMed = Color(0xFFB1720C);
  // static const Color temperatureHigh = Color(0xFF913225);

  // static const Color info = Colors.blue;
  // static const Color debug = Colors.brown;
  // static const Color success = Colors.green;
  // static const Color warning = temperatureMed;
  // static const Color error = temperatureHigh;

  static const Color enabled = Colors.green;
  static const Color disabled = Colors.orange;
  static const Color unknown = Colors.grey;
  static const Color blocked = Colors.red;
  static const Color forwarded = Colors.green;
  static const Color cached = Colors.blue;
  static const Color code = Color(0xFF303030);

  // static const Color totalQueries = Color(0xFF005C32);
  // static const Color queriesBlocked = Color(0xFF007997);
  // static const Color percentBlocked = Color(0xFFB1720C);
  // static const Color domainsOnBlocklist = Color(0xFF913225);
}
