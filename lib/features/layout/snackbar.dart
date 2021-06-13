import 'package:flutter/material.dart';

extension ScaffoldMessengerStateX on ScaffoldMessengerState {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBarNow(
      SnackBar snackBar) {
    clearSnackBars();
    return showSnackBar(snackBar);
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      showThemedMessageNow(
    BuildContext context, {
    required String message,
    Widget? leading,
  }) {
    return showSnackBarNow(SnackBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      content: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          leading != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: leading,
                )
              : Container(
                  height: 0,
                ),
          Text(
            message,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
        ],
      ),
      duration: Duration(seconds: 3),
    ));
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showMessageNow(
    BuildContext context, {
    required String message,
    Widget? leading,
  }) {
    return showSnackBarNow(SnackBar(
      content: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          leading != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: leading,
                )
              : Container(
                  height: 0,
                ),
          Text(
            message,
          ),
        ],
      ),
      duration: Duration(seconds: 3),
    ));
  }
}

final importSnackBarMixins = null;
