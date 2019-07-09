import 'package:fluro/fluro.dart';
import 'package:flutterhole_again/service/pihole_client.dart';

import 'local_storage.dart';

/// Globally accessible class.
class Globals {
  static Router router;
  static PiholeClient client;
  static LocalStorage localStorage;
}
