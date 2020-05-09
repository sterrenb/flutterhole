import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class Constants {
  Constants._();

  static const String piholeSettingsSubDirectory = 'piholes';
  static const String piholeSettingsActive = 'active';
}

class KIcons {
  KIcons._();

  static const IconData connectionStatus = Icons.brightness_1;
  static const IconData toggleEnable = Icons.play_arrow;
  static const IconData toggleDisable = Icons.pause;

  static const IconData summary = Ionicons.md_stats;

  static const IconData dashboard = MaterialCommunityIcons.view_dashboard;
  static const IconData clients = MaterialCommunityIcons.laptop_windows;
  static const IconData domains =
      MaterialCommunityIcons.checkbox_multiple_blank_circle_outline;
  static const IconData permittedDomains = Icons.check;
  static const IconData blockedDomains = Icons.close;
  static const IconData manyQueriesLive = MaterialIcons.view_stream;
  static const IconData manyQueriesLiveOptions = Ionicons.md_options;
  static const IconData settings = MaterialIcons.settings;
  static const IconData about = MaterialCommunityIcons.heart;
  static const IconData log = AntDesign.codesquare;

  static const IconData open = MaterialIcons.keyboard_arrow_right;
  static const IconData close = Icons.close;
  static const IconData openInBrowser = MaterialIcons.open_in_browser;
  static const IconData copy = Icons.content_copy;
  static const IconData save = Icons.check;
  static const IconData filter_active = MaterialCommunityIcons.filter;
  static const IconData filter_inactive = MaterialCommunityIcons.filter_outline;

  static const IconData info = Icons.info;
  static const IconData debug = Icons.bug_report;
  static const IconData warning = Icons.warning;
  static const IconData error = Icons.close;
  static const IconData success = Icons.check;

  static const IconData date = Ionicons.md_calendar;
  static const IconData qrCode = AntDesign.qrcode;
  static const IconData visibility_on = MaterialIcons.visibility;
  static const IconData visibility_off = MaterialIcons.visibility_off;
  static const IconData version = MaterialIcons.developer_board;
  static const IconData color = Icons.brightness_1;

  static const IconData share = MaterialIcons.share;
  static const IconData rate = Icons.star;
  static const IconData github = AntDesign.github;
  static const IconData privacy = Icons.lock;
  static const IconData pihole = MaterialCommunityIcons.raspberry_pi;
  static const IconData bugReport = Icons.bug_report;

  static const IconData queryStatus = Fontisto.direction_sign;
  static const IconData dnsSec = MaterialCommunityIcons.dns;
  static const IconData timestamp = MaterialCommunityIcons.timelapse;
  static const IconData pingInterval = MaterialCommunityIcons.timer_sand;
  static const IconData resultWindowSize = MaterialCommunityIcons.view_array;

  static const IconData baseUrl = MaterialIcons.router;
  static const IconData apiPath = Icons.code;
  static const IconData apiToken = MaterialCommunityIcons.key_variant;
  static const IconData apiPort = Icons.adjust;
  static const IconData description = MaterialIcons.description;
  static const IconData allowSelfSignedCertificates = Ionicons.md_unlock;
  static const IconData basicAuthenticationUsername = AntDesign.user;
  static const IconData basicAuthenticationPassword = AntDesign.key;
}

class KColors {
  KColors._();

  static const Color inactive = Colors.grey;
  static const Color summary = Colors.green;
  static const Color clients = Colors.blue;
  static const Color domains = Colors.orange;
  static const Color settings = Colors.red;

  static const Color queryStatus = Colors.brown;
  static const Color dnsSec = Colors.blueGrey;
  static const Color timestamp = Colors.amber;

  static const Color info = Colors.blue;
  static const Color debug = Colors.brown;
  static const Color warning = Colors.orange;
  static const Color success = Colors.green;
  static const Color error = Colors.red;
}
