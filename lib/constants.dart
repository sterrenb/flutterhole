import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class KStrings {
  KStrings._();

  static const String piholeSettingsSubDirectory = 'piholes';
  static const String piholeSettingsActive = 'active';
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

  static const IconData connectionStatus = Icons.brightness_1;
  static const IconData toggleEnable = Icons.play_arrow;
  static const IconData toggleDisable = Icons.pause;
  static const IconData sleep = MaterialCommunityIcons.sleep;
  static const IconData wake = MaterialCommunityIcons.bell_ring;

  static const IconData temperature = MaterialCommunityIcons.fire;
  static const IconData cpuLoad = MaterialCommunityIcons.server;
  static const IconData memoryUsage = MaterialCommunityIcons.memory;

  static const IconData themeSystem = Feather.sunrise;
  static const IconData themeLight = Feather.sun;
  static const IconData themeDark = Feather.moon;
  static const IconData welcome = MaterialCommunityIcons.message_text;

  static const IconData dashboard = MaterialCommunityIcons.view_dashboard;
  static const IconData queryLog = MaterialCommunityIcons.file_document;
  static const IconData clients = MaterialCommunityIcons.laptop_windows;
  static const IconData domains =
      MaterialCommunityIcons.checkbox_multiple_blank_circle_outline;
  static const IconData summary = Ionicons.md_stats;
  static const IconData permittedDomains = Icons.check;
  static const IconData blockedDomains = Icons.close;
  static const IconData manyQueriesLive = MaterialIcons.view_stream;
  static const IconData manyQueriesLiveOptions = Ionicons.md_options;
  static const IconData whitelist = MaterialCommunityIcons.check_circle;
  static const IconData blacklist = MaterialCommunityIcons.close_circle;
  static const IconData settings = MaterialIcons.settings;
  static const IconData preferences = MaterialIcons.format_paint;
  static const IconData about = MaterialCommunityIcons.heart;
  static const IconData apiLog = AntDesign.codesquare;

  static const IconData open = MaterialIcons.keyboard_arrow_right;
  static const IconData search = MaterialIcons.search;
  static const IconData close = Icons.close;
  static const IconData back = Icons.arrow_back;
  static const IconData delete = MaterialCommunityIcons.delete_circle;
  static const IconData openInBrowser = MaterialIcons.open_in_browser;
  static const IconData copy = Icons.content_copy;
  static const IconData save = Icons.check;
  static const IconData moreInfo = MaterialIcons.info_outline;
  static const IconData filter_active = MaterialCommunityIcons.filter;
  static const IconData filter_inactive = MaterialCommunityIcons.filter_outline;

  static const IconData info = Icons.info;
  static const IconData debug = Icons.bug_report;
  static const IconData warning = Icons.warning;
  static const IconData error = Icons.close;
  static const IconData success = Icons.check;
  static const IconData unknown = MaterialCommunityIcons.cloud_question;
  static const IconData forwarded = MaterialCommunityIcons.fast_forward;
  static const IconData blocked = Icons.block;
  static const IconData cached = MaterialIcons.cached;

  static const IconData date = Ionicons.md_calendar;
  static const IconData qrCode = AntDesign.qrcode;
  static const IconData visibility_on = MaterialIcons.visibility;
  static const IconData visibility_off = MaterialIcons.visibility_off;
  static const IconData version = MaterialIcons.developer_board;
  static const IconData branch = MaterialCommunityIcons.source_branch;
  static const IconData color = Icons.brightness_1;

  static const IconData add = Icons.add;
  static const IconData share = MaterialIcons.share;
  static const IconData rate = Icons.star;
  static const IconData github = AntDesign.github;
  static const IconData privacy = Icons.lock;
  static const IconData pihole = MaterialCommunityIcons.raspberry_pi;
  static const IconData bugReport = Icons.bug_report;

  static const IconData queryStatus = Fontisto.direction_sign;
  static const IconData queryType = MaterialIcons.merge_type;
  static const IconData timestamp = MaterialCommunityIcons.timelapse;
  static const IconData pingInterval = MaterialCommunityIcons.timer_sand;
  static const IconData resultWindowSize = MaterialCommunityIcons.view_array;

  static const IconData annotation = MaterialCommunityIcons.tag;
  static const IconData hostDetails = MaterialCommunityIcons.server;
  static const IconData authentication = Ionicons.md_lock;
  static const IconData baseUrl = MaterialIcons.router;
  static const IconData apiPath = Icons.code;
  static const IconData apiToken = MaterialCommunityIcons.key_variant;
  static const IconData apiPort = Icons.adjust;
  static const IconData description = MaterialIcons.description;
  static const IconData basicAuthenticationUsername = AntDesign.user;
  static const IconData basicAuthenticationPassword = AntDesign.key;
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
