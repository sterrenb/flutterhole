import 'package:flutter/material.dart';

void highlightSnackBar(BuildContext context, Widget content,
    [Duration duration = const Duration(seconds: 2)]) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: content,
    duration: duration,
  ));
}
