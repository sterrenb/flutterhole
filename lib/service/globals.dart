import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterhole/service/memory_tree.dart';
import 'package:flutterhole/service/pihole_client.dart';
import 'package:flutterhole/service/secure_store.dart';


/// Globally accessible class.
class Globals {
  static bool debug = false;
  static MemoryTree tree;
  static Router router;
  static PiholeClient client;

//  static LocalStorage localStorage;
  static SecureStore secureStore;

  static VoidCallback refreshAllBlocs;

  static Future<dynamic> navigateTo(BuildContext context, String path) =>
      router.navigateTo(context, path, transition: TransitionType.inFromRight);
}
