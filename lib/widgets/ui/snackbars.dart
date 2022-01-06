import 'package:flutter/material.dart';

void highlightSnackBar(
  BuildContext context, {
  required Widget content,
  VoidCallback? undo,
  Duration duration = const Duration(seconds: 4),
}) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: content,
    duration: duration,
    behavior: SnackBarBehavior.floating,
    action: undo == null
        ? null
        : SnackBarAction(
            label: 'Undo',
            onPressed: undo,
          ),
  ));
}
