import 'package:flutter/material.dart';
import 'package:flutterhole/core/models/failures.dart';

Future<void> showWelcomeDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text('FlutterHole V5'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                  'Thank you for trying out FlutterHole, a third party Android application for the Pi-Hole® dashboard.\n'),
              Text(
                  'To make full use of this app, you need to enter an API token. You can find this in the dashboard of your Pi-hole. Check Settings > My Pi-holes to enter your token.\n'),
              Text(
                  'Note: some users experience issues when upgrading from version 2.x. Re-installing the app after clearing the cache works for some people.\n'),
              Text(
                  'If you have any issues, please report them on GitHub. Other users can share their own issues and solutions here.')
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Got it!'),
          ),
        ],
      );
    },
  );
}

Future<bool> showConfirmationDialog(
  BuildContext context, {
  Widget title,
}) async {
  final result = await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: title ?? Text('Confirm'),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            OutlineButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      });

  return result ?? false;
}

Future<void> showFailureDialog(
  BuildContext context,
  Failure failure, {
  Widget title,
}) async {
  showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: title,
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('${failure?.message ?? 'unknown failure'}'),
              Text('${failure?.error?.toString() ?? ''}'),
            ],
          ),
        ),
      );
    },
  );
}
