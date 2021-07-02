import 'package:flutter/material.dart';
import 'package:flutterhole_web/features/browser_helpers.dart';
import 'package:flutterhole_web/features/layout/snackbar.dart';

const importContextExtensions = null;

final x = importSnackBarExtensions;

extension BuildContextX on BuildContext {
  Future<void> openUrl(String url) async {
    if (!await launchUrl(url)) {
      ScaffoldMessenger.of(this).showMessageNow(message: 'Cannot open $url');
    }
  }

  bool get isLight => Theme.of(this).brightness == Brightness.light;
}
