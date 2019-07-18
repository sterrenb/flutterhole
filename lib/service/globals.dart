import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterhole/service/pihole_client.dart';

import 'local_storage.dart';

/// Globally accessible class.
class Globals {
  static bool debug = false;
  static Router router;
  static PiholeClient client;
  static LocalStorage localStorage;

  static VoidCallback refresh;
}
