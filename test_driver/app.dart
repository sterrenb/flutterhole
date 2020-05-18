import 'package:flutter/widgets.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutterhole/main.dart' as app;
import 'package:injectable/injectable.dart';

main() {
  enableFlutterDriverExtension();
  WidgetsApp.debugAllowBannerOverride =
      false; // remove debug banner for screenshots
  app.main([Environment.dev]);
}
