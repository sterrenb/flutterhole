import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutterhole_web/entities.dart';

final debugPis = <Pi>[
  Pi(
    title: 'My hole',
    description: '',
    primaryColor: Colors.purple,
    baseUrl: 'http://10.0.1.5',
    apiPath: 'admin/api.php',
    apiPort: 80,
    apiToken: '',
    apiTokenRequired: true,
    allowSelfSignedCertificates: false,
    basicAuthenticationUsername: '',
    basicAuthenticationPassword: '',
    proxyUrl: '',
    proxyPort: 8080,
  ),
  Pi(
    title: 'Broken',
    description: 'This won\'t work',
    primaryColor: Colors.orange,
    baseUrl: 'http://example.com',
    apiPath: 'admin/api.php',
    apiPort: 80,
    apiToken: '',
    apiTokenRequired: true,
    allowSelfSignedCertificates: false,
    basicAuthenticationUsername: '',
    basicAuthenticationPassword: 'null',
    proxyUrl: '',
    proxyPort: 8080,
  )
];

class KStrings {
  KStrings._();

  static const String privacyUrl =
      'https://raw.githubusercontent.com/sterrenburg/flutterhole/master/PRIVACY.md';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=sterrenburg.github.flutterhole';
  static const String githubHomeUrl =
      'https://github.com/sterrenburg/flutterhole/';
  static const String githubIssuesUrl =
      'https://github.com/sterrenburg/flutterhole/issues/new/choose';
  static const String logoDesignerUrl = 'https://mathijssterrenburg.com/';
}

class KIcons {
  KIcons._();

  static const IconData lightTheme = MaterialIcons.wb_sunny;
  static const IconData darkTheme = MaterialIcons.wb_cloudy;
  static const IconData systemTheme = MaterialIcons.wb_auto;

  static const IconData piholeTitle = Icons.handyman_sharp;

  static const IconData temperatureReading = MaterialCommunityIcons.thermometer;
  static const IconData memoryUsage = MaterialCommunityIcons.memory;
  static const IconData updateFrequency = MaterialCommunityIcons.update;
  static const IconData refresh = MaterialCommunityIcons.refresh;

  static const IconData appVersion = MaterialIcons.developer_board;
  static const IconData pihole = MaterialCommunityIcons.raspberry_pi;

  static const IconData settings = MaterialIcons.settings;
  static const IconData dot = Icons.brightness_1;
  static const IconData totalQueries = MaterialCommunityIcons.earth;
  static const IconData queriesBlocked = MaterialCommunityIcons.hand_left;
  static const IconData percentBlocked = MaterialCommunityIcons.chart_pie;
  static const IconData domainsOnBlocklist =
      MaterialCommunityIcons.playlist_remove;
}

class KColors {
  KColors._();

  static const Color inactive = Colors.grey;
  static const Color loading = Colors.blue;
  static const Color sleeping = Colors.blue;
  static const Color summary = Colors.green;
  static const Color clients = Colors.blue;
  static const Color domains = Colors.orange;
  static const Color settings = Colors.red;

  static const Color queryStatus = Colors.brown;
  static const Color dnsSec = Colors.blueGrey;
  static const Color timestamp = Colors.amber;
  static const Color link = Colors.blue;

  static const Color info = Colors.blue;
  static const Color debug = Colors.brown;
  static const Color warning = Colors.orange;
  static const Color success = Colors.green;
  static const Color error = Colors.red;

  static const Color enabled = Colors.green;
  static const Color disabled = Colors.orange;
  static const Color unknown = Colors.grey;
  static const Color blocked = Colors.red;
  static const Color forwarded = Colors.green;
  static const Color cached = Colors.blue;
}
